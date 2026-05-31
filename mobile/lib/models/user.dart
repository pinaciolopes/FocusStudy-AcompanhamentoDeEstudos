// Models para usuário e autenticação
class User {
  final String username;
  final String email;
  final String? password;

  User({
    required this.username,
    required this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      if (password != null) 'password': password,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
    );
  }
}

class AuthResponse {
  final String access;
  final String refresh;

  AuthResponse({
    required this.access,
    required this.refresh,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      access: json['access'],
      refresh: json['refresh'],
    );
  }
}

class ApiResponse {
  final bool sucesso;
  final String mensagem;

  ApiResponse({
    required this.sucesso,
    required this.mensagem,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      sucesso: json['sucesso'] ?? false,
      mensagem: json['mensagem'] ?? '',
    );
  }
}