const apiUrl = 'https://whnuzf2r2k.execute-api.eu-west-2.amazonaws.com/VisitorCounterLambda';
const visitorCountElement = document.getElementById('visitor-count');
const errorMessageElement = document.getElementById('error-message');

async function updateVisitorCount() {
    try {
        // Increment visitor count
        const response = await fetch(apiUrl, {
            method: 'POST'
        });

        if (!response.ok) {
            throw new Error('Failed to fetch visitor count.');
        }
        const data = await response.json();
        const count = data.visitCount;
        // api request to get trivia with visitor count
        const triviaUrl = `https://corsproxy.io/?url=http://numbersapi.com/${count}/trivia?json`;
        const triviaResponse =  await fetch(triviaUrl);
        if (!triviaResponse.ok) {
            throw new Error('Failed to fetch trivia.');
        }
       
        const triviaData = await triviaResponse.json();
        const trivia = triviaData.text || 'No trivia available';

        // Display visitor count in the 'visitor-count' element
        visitorCountElement.innerText = `${count} visitors - ${trivia}`;
    } catch (error) {
        visitorCountElement.textContent = 'Error loading visitor count';
        errorMessageElement.textContent = `Error Message: ${error.message}`;
    }
}

// Call updateVisitorCount on page load
window.onload = updateVisitorCount;
