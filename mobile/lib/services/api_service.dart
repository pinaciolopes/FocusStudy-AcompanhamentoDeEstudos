import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/materia.dart';
import '../models/sessao.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  final String? token;
  
  ApiService({this.token});

  // ==========================================
  // MÉTODOS DE AUTENTICAÇÃO
  // ==========================================

  // Login do usuário
  static Future<AuthResponse?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/pair'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  // Registrar novo usuário
  static Future<ApiResponse?> registrar(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data);
      }
      return ApiResponse(
        sucesso: false,
        mensagem: data['mensagem'] ?? 'Erro ao criar conta',
      );
    } catch (e) {
      print('Erro no registro: $e');
      return ApiResponse(
        sucesso: false,
        mensagem: 'Erro de conexão com o servidor',
      );
    }
  }

  // Deletar própria conta
  Future<ApiResponse?> deletarConta() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Remove token após deletar conta
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        return ApiResponse.fromJson(data);
      }
      return ApiResponse(
        sucesso: false,
        mensagem: data['mensagem'] ?? 'Erro ao deletar conta',
      );
    } catch (e) {
      print('Erro ao deletar conta: $e');
      return ApiResponse(
        sucesso: false,
        mensagem: 'Erro de conexão com o servidor',
      );
    }
  }

  // ==========================================
  // MÉTODOS DE MATÉRIAS
  // ==========================================

  // Listar todas as matérias
  Future<List<Materia>> getMaterias() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/materias'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => Materia.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao carregar matérias: $e');
      return [];
    }
  }

  // Criar nova matéria
  Future<Materia?> createMateria(String nome) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/materias'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'nome': nome}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Materia.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao criar matéria: $e');
      return null;
    }
  }

  // Atualizar matéria
  Future<Materia?> updateMateria(int id, String nome) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/materias/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'nome': nome}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Materia.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar matéria: $e');
      return null;
    }
  }

  // Deletar matéria
  Future<bool> deleteMateria(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/materias/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao deletar matéria: $e');
      return false;
    }
  }

  // ==========================================
  // MÉTODOS DE SESSÕES
  // ==========================================

  // Listar todas as sessões
  Future<List<SessaoEstudo>> getSessoes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessoes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => SessaoEstudo.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao carregar sessões: $e');
      return [];
    }
  }

  // Criar nova sessão
  Future<SessaoEstudo?> createSessao(SessaoEstudo sessao) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessoes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(sessao.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return SessaoEstudo.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao criar sessão: $e');
      return null;
    }
  }

  // Atualizar sessão
  Future<SessaoEstudo?> updateSessao(int id, SessaoEstudo sessao) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/sessoes/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(sessao.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SessaoEstudo.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar sessão: $e');
      return null;
    }
  }

  // Deletar sessão
  Future<bool> deleteSessao(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/sessoes/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao deletar sessão: $e');
      return false;
    }
  }

  // ==========================================
  // MÉTODOS UTILITÁRIOS
  // ==========================================

  // Salvar token no SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Recuperar token do SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Remover token (logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}