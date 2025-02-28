const apiUrl = 'https://whnuzf2r2k.execute-api.eu-west-2.amazonaws.com/VisitorCounterLambda';

async function updateVisitorCount() {
    try {
        // Increment and get visitor count
        const response = await fetch(apiUrl, {
            method: 'POST'
        });
        
        const visitorCountElement = document.getElementById('visitor-count');

        // Handle error and set visitor count element
        if (!response.ok) {
            visitorCountElement.textContent = 'Error loading visitor count';
            throw new Error('Failed to fetch visitor count.');
        }
        const data = await response.json();
        const count = data.visitCount;

        // Api request to get trivia with visitor count
        const triviaUrl = `https://corsproxy.io/?url=http://numbersapi.com/${count}/trivia?json`;
        const triviaResponse =  await fetch(triviaUrl);

        // Handle error and set visitor count element
        if (!triviaResponse.ok) {
            const trivia = 'No trivia available';
            visitorCountElement.textContent = `${count} visitors - ${trivia}`;
            throw new Error('Failed to fetch trivia.');
        }
       
        const triviaData = await triviaResponse.json();
        const trivia = triviaData.text || 'No trivia available';
        
        // Display visitor count in the 'visitor-count' element
        visitorCountElement.textContent = `${count} visitors - ${trivia}`;
    } catch (error) {
        const errorMessageElement = document.getElementById('error-message');
        errorMessageElement.textContent = `Error Message: ${error.message}`;
    }
}

// Call updateVisitorCount on page load
window.onload = updateVisitorCount;

module.exports = { updateVisitorCount }; 