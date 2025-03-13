import boto3
import pytest
import os
import json
from unittest.mock import patch
from moto import mock_aws

from src.VisitorCounterLambda import (
    lambda_handler,
    increment_visitor_count,
    get_visitor_count,
)

# test credentials fixture
@pytest.fixture(scope="function", autouse=True)
def mock_creds(monkeypatch):
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "test")
    monkeypatch.setenv("AWS_SECURITY_TOKEN", "test")
    monkeypatch.setenv("AWS_SESSION_TOKEN", "test")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "test")
    monkeypatch.setenv("AWS_USER", "test")


# mock dynamodb fixture
@pytest.fixture()
def ddb_mock():
    with mock_aws():
        ddb = boto3.resource("dynamodb", region_name='us-east-1')
        yield ddb

# mock dynamodb with Visitor Counter Table
@pytest.fixture()
def ddb_with_table(ddb_mock):
    table = ddb_mock.create_table(
            TableName='VisitorCounter',
            KeySchema=[
                {
                    'AttributeName': 'id',
                    'KeyType': 'HASH'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'id',
                    'AttributeType': 'S'
                }
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
            }
    )
    table.put_item(Item={'id': 'VisitCount', 'visitCount': 1234, 'timestamp': "1234"})
    yield ddb_mock

class TestIncrementCounter:
    def test_increments_count(self, ddb_with_table):
        response = ddb_with_table.Table("VisitorCounter").get_item(Key={'id': 'VisitCount'})
        assert response['Item']['visitCount'] == 1234
        increment_visitor_count(ddb_with_table.Table("VisitorCounter"))
        response = ddb_with_table.Table("VisitorCounter").get_item(Key={'id': 'VisitCount'})
        assert response['Item']['visitCount'] == 1235

    @patch("src.VisitorCounterLambda.datetime")
    def test_returns_200_and_updated_table(self, mock_datetime, ddb_with_table):
        mock_datetime.now.return_value = "test"
        response = increment_visitor_count(ddb_with_table.Table("VisitorCounter"))
        assert response['statusCode'] == 200
        expected = json.dumps({"visitCount": 1235, "timestamp": "test"})
        assert response['body'] == expected


    @patch("src.VisitorCounterLambda.datetime")
    def test_timestamps(self, mock_datetime, ddb_with_table):
        mock_datetime.now.return_value = "test"
        increment_visitor_count(ddb_with_table.Table("VisitorCounter"))
        response = ddb_with_table.Table("VisitorCounter").get_item(Key={'id': 'VisitCount'})
        assert response['Item']['timestamp'] == "test"

    def test_handles_table_error(self, ddb_mock):
        response = increment_visitor_count(ddb_mock.Table('test'))
        assert response['statusCode'] == 500
        assert "ResourceNotFoundException" in response['error']

class TestGetCount:
    def test_gets_count(self, ddb_with_table):
        response = get_visitor_count(ddb_with_table.Table("VisitorCounter"))
        assert response['statusCode'] == 200
        assert response['body'] == json.dumps({"id": "VisitCount", "visitCount": 1234, "timestamp": "1234"})

    def test_handles_table_item_error(self, ddb_mock):
        table = ddb_mock.create_table(
            TableName='VisitorCounter',
            KeySchema=[
                {
                    'AttributeName': 'id',
                    'KeyType': 'HASH'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'id',
                    'AttributeType': 'S'
                }
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
            }
    )
        response = get_visitor_count(ddb_mock.Table('VisitorCounter'))
        assert response['statusCode'] == 500
        assert response['body'] == json.dumps('Item not found')

    def test_handles_visit_count_attr_not_present(self, ddb_mock):
        table = ddb_mock.create_table(
            TableName='VisitorCounter',
            KeySchema=[
                {
                    'AttributeName': 'id',
                    'KeyType': 'HASH'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'id',
                    'AttributeType': 'S'
                }
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
            }
    )
        table.put_item(Item={'id': 'VisitCount', 'test': 1234, 'timestamp': "1234"})
        response = get_visitor_count(ddb_mock.Table('VisitorCounter'))
        assert response['statusCode'] == 500
        assert response['body'] == json.dumps('visitCount not found')
        assert response['error'] == json.dumps({"KeyError": "'visitCount'"})

# HAPPY PATHS
# Correct Events
# Visitor Count returned
# Assert handler invokes functions once
# Visitor Count incremented

# SAD PATHS
# Handles malformed event input
# Returns 500 for table error
