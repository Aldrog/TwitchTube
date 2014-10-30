.pragma library

function getRequest(url,callback) {
	var request = new XMLHttpRequest()
	request.open('GET', url)
	request.onreadystatechange = function() {
		if (request.readyState === XMLHttpRequest.DONE) {
			if (request.status && request.status === 200) {
				console.log("response", request.responseText)
				callback(request.responseText)
			} else {
				console.log("HTTP:", request.status, request.statusText)
				callback(false)
			}
		}
	}
	request.send()
}
