/**
 * @jest-environment jsdom
 */

const { updateVisitorCount } = require('./app');
const { waitFor } = require('@testing-library/dom'); // Correct import path
const fetchMock = require('jest-fetch-mock');
fetchMock.enableMocks();


beforeEach(() => {
    document.body.innerHTML = `
        <section id="visitorcounter">
            <div id="visitor-count">Loading visitor count...</div>
            <div id="error-message"></div>
        </section>
    `;
    fetch.resetMocks();
});


test('updates visitor count and trivia successfully', async () => {
  fetch.mockResponseOnce(JSON.stringify({ visitCount: 10 }), { status: 200 });
  fetch.mockResponseOnce(JSON.stringify({ text: '10 is a prime number!' }), { status: 200 });


  updateVisitorCount();

  await waitFor(() => {
    const visitorCountElement = document.getElementById('visitor-count');
    expect(visitorCountElement.textContent).toBe('10 visitors - 10 is a prime number!');
    const errorMessageElement = document.getElementById('error-message');
    expect(errorMessageElement.textContent).toBe('');
  })
});


test('handles error when fetching visitor count', async () => {
  // Mocking the first fetch call to simulate an error (visitor count)
  fetch.mockResponseOnce(
    JSON.stringify({ error: 'Failed to fetch visitor count' }), // Mocking error body
    { status: 500 } // Status code 500 (Internal Server Error)
  );  
  // Call the function that should handle the error
  await updateVisitorCount();

  // Check that the error message is displayed correctly
  const visitorCountElement = document.getElementById('visitor-count');
  const errorMessageElement = document.getElementById('error-message');

  expect(visitorCountElement.textContent).toBe('Error loading visitor count');
  expect(errorMessageElement.textContent).toBe('Error Message: Failed to fetch visitor count.');
});

test('handles error when fetching trivia', async () => {
  fetch.mockResponseOnce(
    JSON.stringify({ visitCount: 5 }),
    { status: 200 } 
  );
  
  fetch.mockResponseOnce(
    JSON.stringify({ error: 'Failed to fetch trivia' }), 
    { status: 500 } 
  );

  await updateVisitorCount();

  // Check that the visitor count is displayed correctly but the trivia error is handled
  await waitFor(() => {
    const visitorCountElement = document.getElementById('visitor-count');
    expect(visitorCountElement.textContent).toBe('5 visitors - No trivia available');
    const errorMessageElement = document.getElementById('error-message');
    expect(errorMessageElement.textContent).toBe('Error Message: Failed to fetch trivia.');
  })
});

test('handles multiple fetch errors (visitor count and trivia)', async () => {
  // Mocking the first fetch call to simulate an error (visitor count)
  fetch.mockResponseOnce(
    JSON.stringify({ error: 'Failed to fetch visitor count' }), // Mocking error body
    { status: 500 } // Status code 500 (Internal Server Error)
  );  

  fetch.mockResponseOnce(
    JSON.stringify({ error: 'Failed to fetch trivia' }), // Mocking error body
    { status: 500 } // Status code 500 (Internal Server Error)
  );
  
  // Call the function that should handle the error
  await updateVisitorCount();

  // Check that the error message for both fetch calls is displayed
  const visitorCountElement = document.getElementById('visitor-count');
  const errorMessageElement = document.getElementById('error-message');

  expect(visitorCountElement.textContent).toBe('Error loading visitor count');
  expect(errorMessageElement.textContent).toBe('Error Message: Failed to fetch visitor count.');
});

