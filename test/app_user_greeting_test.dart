import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/models/app_user.dart';

void main() {
  group('AppUser.homeGreeting', () {
    test('usa o primeiro nome quando existe', () {
      final user = AppUser(id: '1', name: 'Maria Silva', email: 'm@a.com');
      expect(user.firstName, 'Maria');
      expect(user.homeGreeting, 'Olá, Maria!');
      expect(user.profileDisplayName, 'Maria Silva');
      expect(user.avatarInitial, 'M');
    });

    test('não mostra vírgula vazia quando o nome está em branco', () {
      final user = AppUser(id: '1', name: '   ', email: 'm@a.com');
      expect(user.firstName, isEmpty);
      expect(user.homeGreeting, 'Olá!');
      expect(user.profileDisplayName, 'Aluno');
      expect(user.avatarInitial, 'M');
    });

    test('não inventa nome próprio', () {
      final user = AppUser(id: '1', name: '', email: '');
      expect(user.homeGreeting, isNot(contains('Ana')));
      expect(user.homeGreeting, isNot(contains(', !')));
      expect(user.homeGreeting, 'Olá!');
    });
  });

  group('AppUser.fromMap nome', () {
    test('lê name', () {
      final user = AppUser.fromMap('u1', {'name': 'Joana', 'email': 'j@a.com'});
      expect(user.name, 'Joana');
      expect(user.homeGreeting, 'Olá, Joana!');
    });

    test('cai em displayName se name estiver vazio', () {
      final user = AppUser.fromMap('u1', {
        'name': '',
        'displayName': 'Carla Souza',
        'email': 'c@a.com',
      });
      expect(user.name, 'Carla Souza');
      expect(user.homeGreeting, 'Olá, Carla!');
    });

    test('aceita nome e fullName', () {
      expect(
        AppUser.fromMap('u1', {'nome': 'Patrícia'}).name,
        'Patrícia',
      );
      expect(
        AppUser.fromMap('u1', {'fullName': 'Ana Clara'}).firstName,
        'Ana',
      );
    });
  });
}
