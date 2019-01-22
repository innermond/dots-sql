select u.id, u.username, u.password, u.api_key, group_concat(ur.role_name) roles from users u join user_roles ur on u.id = ur.user_id where u.username = 'gabiuser1' group by u.id;
