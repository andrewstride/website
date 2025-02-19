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
        const count = data.visitCount
        // Display visitor count in the 'visitor-count' element
        visitorCountElement.innerText = `${count} visitors`;
    } catch (error) {
        visitorCountElement.textContent = 'Error loading visitor count';
        errorMessageElement.textContent = `Error Message: ${error.message}`;
    }
}

// Call updateVisitorCount on page load
window.onload = updateVisitorCount;
