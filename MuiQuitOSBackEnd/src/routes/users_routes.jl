function users_routes(req)
    if startswith(req.target, "/users")
        return handle_users(req)
    end
    return nothing
end
