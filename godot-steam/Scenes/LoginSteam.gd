extends Control

var steam_auth_ticket : Dictionary


func _ready() -> void:
	PlayFabManager.client.logged_in.connect(_on_logged_in)
	PlayFabManager.client.api_error.connect(_on_api_error)
	PlayFabManager.client.server_error.connect(_on_server_error)
	Steam.get_auth_session_ticket_response.connect(_on_get_auth_sesssion_ticket)
	Steam.get_ticket_for_web_api.connect(_on_get_auth_ticket_for_web_api_response)

	var result : Dictionary = Steam.steamInitEx(false) # Set to true if you want some local user's data
	if result.status > 0:
		print("Failure to initialize Steam with status %s" % result.status)
	else:
		#create_auth_session_ticket()
		create_auth_ticket_for_web_api() #Use this line instead if you need Steam Auth Ticket for Web Api

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func _exit_tree() -> void:
	if steam_auth_ticket.size() > 0:
		cancel_auth_ticket()

func _on_logged_in(login_result: LoginResult) -> void:
	print("Playfab Login successful: %s" % login_result)

func _on_api_error(error_wrapper: ApiErrorWrapper) -> void:
	print("Playfab API Error: %s" % error_wrapper.errorMessage)

func _on_server_error(error_wrapper: ApiErrorWrapper) -> void:
	print("Playfab Server Error: %s" % error_wrapper.errorMessage)

func login(ticket: String, is_auth_ticket_for_api: bool) -> void:
	var combined_info_request_params = GetPlayerCombinedInfoRequestParams.new()
	combined_info_request_params.show_all()
	var player_profile_view_constraints = PlayerProfileViewConstraints.new()
	combined_info_request_params.ProfileConstraints = player_profile_view_constraints
	PlayFabManager.client.login_with_steam(ticket, is_auth_ticket_for_api, true, combined_info_request_params)

func cancel_auth_ticket() -> void:
	Steam.cancelAuthTicket(steam_auth_ticket.id)

func create_auth_session_ticket() -> void:
	steam_auth_ticket = Steam.getAuthSessionTicket()

func create_auth_ticket_for_web_api() -> void:
	Steam.getAuthTicketForWebApi("AzurePlayFab")

func convert_auth_ticket() -> String:
	var ticket: String = ""
	for number in steam_auth_ticket.buffer:
		ticket += "%02X" % number
	return ticket

func _on_get_auth_sesssion_ticket(auth_ticket_id: int, result: int) -> void:
	print("Auth Session Ticket (%s) return with result %s" % [auth_ticket_id, result])
	if result == 1:
		login(convert_auth_ticket(), false)

func _on_get_auth_ticket_for_web_api_response(auth_ticket: int, result: int, ticket_size: int, ticket_buffer: Array) -> void:
	print("Auth Ticket for Web API (%s) return with the result %s" % [auth_ticket, result])
	steam_auth_ticket.id = auth_ticket
	steam_auth_ticket.buffer = ticket_buffer
	steam_auth_ticket.size = ticket_size
	if result == 1:
		login(convert_auth_ticket(), true)
