// app/assets/javascripts/articles.js
document.addEventListener('DOMContentLoaded', function () {
  var typingTimer;

  // Function to execute when typing is done
  function doneTyping() {
    var searchTerm = document.getElementById('search_term').value;
    // Make an AJAX request to update search results
    updateSearchResults(searchTerm);
  }

  // Function to make an AJAX request and update search results
  function updateSearchResults(searchTerm) {
    $.ajax({
      url: '/articles',
      type: 'GET',
      data: { term: searchTerm },
      dataType: 'script', // Expecting JavaScript response
      success: function (response) {
        // Handle success if needed
        $('#articles').html(response);
      },
      error: function (error) {
        console.error('Error:', error.responseText);
      },
    });
  }

  // Listen for input events on the search term field
  document
    .getElementById('search_term')
    .addEventListener('input', function () {
      clearTimeout(typingTimer);
      typingTimer = setTimeout(doneTyping, 500);
    });
});
