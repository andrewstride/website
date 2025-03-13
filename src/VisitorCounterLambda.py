import json
import boto3
from datetime import datetime


def lambda_handler(event, context):
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("VisitorCounter")
    try:
        if event["requestContext"]["http"]["method"] == "POST":
            return increment_visitor_count(table)

        elif event["requestContext"]["http"]["method"] == "GET":
            return get_visitor_count(table)

        else:
            return {"statusCode": 405, "body": json.dumps("Method Not Allowed")}
    except Exception as e:
        return {
            "statusCode": 400,
            "body": json.dumps(
                "Bad Request"
            ),
            "error": json.dumps(str(e)),
        }


def increment_visitor_count(table):
    try:
        response = table.update_item(
            Key={"id": "VisitCount"},
            UpdateExpression="SET visitCount = visitCount + :val, #ts = :timestamp",
            ExpressionAttributeValues={":val": 1, ":timestamp": str(datetime.now())},
            ExpressionAttributeNames={"#ts": "timestamp"},
            ReturnValues="UPDATED_NEW",
        )
        response["Attributes"]["visitCount"] = int(response["Attributes"]["visitCount"])
        return {"statusCode": 200, "body": json.dumps(response["Attributes"])}
    except Exception as e:
        return {"statusCode": 500, "error": json.dumps(str(e))}


def get_visitor_count(table):
    response = table.get_item(Key={"id": "VisitCount"})
    if not response.get('Item'):
        return {
           "statusCode": 500,
            "body": json.dumps("Item not found") 
        }
    try:
        response["Item"]["visitCount"] = int(response["Item"]["visitCount"])
        return {"statusCode": 200, "body": json.dumps(response["Item"])}
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps("visitCount not found"),
            "error": json.dumps({str(type(e).__name__): str(e)})
        }
