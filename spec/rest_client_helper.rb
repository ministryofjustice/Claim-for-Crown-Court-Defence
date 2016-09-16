
def api_get_url(endpoint)
  Settings.remote_api_url + endpoint + '?api_key=' + Settings.remote_api_key
end