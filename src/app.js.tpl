function fetchText() {
    const apiUrl = "${api_gateway_url}";
    fetch(apiUrl)
        .then(response => response.json())
        .then(data => {
            document.getElementById('textOutput').innerText = data.message;
        })
        .catch(error => {
            console.error('Error fetching text:', error);
        });
}

document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('fetchText').addEventListener('click', fetchText);
});