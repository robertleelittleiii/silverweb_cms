// app/assets/javascripts/auth_point_handler.js
function handleAuthPointAuthentication(userId) {
  $.ajax({
    url: '/site/two_factor_ajax',
    method: 'POST',
    data: { user_id: userId },
    success: function(response) {
      if (response.success) {
        showAuthPointNotification(response.message);
        pollAuthPointStatus();
      } else {
        showError(response.error);
      }
    },
    error: function(xhr) {
      showError('Authentication failed. Please try again.');
    }
  });
}

function pollAuthPointStatus() {
  const pollInterval = setInterval(() => {
    $.ajax({
      url: '/site/check_session',
      method: 'POST',
      success: function(response) {
        if (response.authenticated) {
          clearInterval(pollInterval);
          window.location.reload();
        }
      }
    });
  }, 3000);
}
