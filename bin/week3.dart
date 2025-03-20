import 'dart:convert';
import 'dart:io';

class Game {
  String character = "";
  List<Monster> monsters = [];
  int killCountMob = 3;

  void startGame() {
    // 캐릭터 스탯 읽기
    final characterStats = File('data/characters.txt').readAsStringSync().split(',');
    if (characterStats.length == 3) { // HP, ATK, DEF 체크
      character = "Player"; // 캐릭터이름할당
      final player = Character() // 
        ..hp = int.parse(characterStats[0]) // ..은 같은객체에서 연속으로 설정할 때 사용
        ..atk = int.parse(characterStats[1])
        ..def = int.parse(characterStats[2]);
    }

    // 몬스터 스탯 읽기
    final monsterLines = File('data/monsters.txt').readAsLinesSync();
    for (var line in monsterLines) {
      final monsterStats = line.split(',');
      if (monsterStats.length == 3) {
        final monster = Monster() // 3칸짜리 리스트에 저장
          ..name = monsterStats[0]
          ..hp = int.parse(monsterStats[1])
          ..atk = int.parse(monsterStats[2]);
        monsters.add(monster);
      }
    }

    // 사용자로부터 캐릭터 이름 입력받기
    RegExp nameRegExp = RegExp(r'^[a-zA-Z가-힣]+$');
    while (true) {
      stdout.write("캐릭터 이름 입력 (영문 또는 한글만 허용): \n");
      character = stdin.readLineSync(encoding: systemEncoding) ?? "Player"; // 인코딩 설정 추가?
      if (nameRegExp.hasMatch(character)) {
      break;
      } else {
      print("잘못된 입력입니다. 영문 또는 한글만 입력해주세요.");
      }
    }
    print("환영합니다., $character!");


    // 초기화 완료후 게임시작
    
  }

  void battle() {
    // 몬스터 랜덤 생성
    getRandomMonster();

    // 전투 시작
    while (true) {
      // 캐릭터가 몬스터 공격
      character.attackMonster(monsters[0]);

      // 몬스터가 캐릭터 공격
      monsters[0].attackCharacter(character);

      // 전투 종료 체크
      if (character.hp <= 0) {
        print("전투에서 패배했습니다.");
        break;
      } else if (monsters[0].hp <= 0) {
        print("전투에서 승리했습니다.");
        character.killCount++;
        character.exp += monsters[0].exp;
        if (character.exp >= character.expToNextLevel) {
          character.levelUp();
        }
        monsters.removeAt(0);
        if (monsters.isEmpty) {
          print("더 이상 사냥할 몬스터가 없습니다.");
          break;
        }
      }

      // 전투 상태 출력
      character.showStatus();
      monsters[0].showStatus();

      // 사용자 입력 대기
      stdout.write("계속해서 전투를 진행하시겠습니까? (Y/N): ");
      final answer = stdin.readLineSync(encoding: systemEncoding);
      if (answer?.toUpperCase() != "Y") {
        break;
      }
    }
  }

  void getRandomMonster() {

  }
}

class Character {
  String name = "";
  int hp = 100;
  int atk = 10;
  int def = 5;
  int level = 1;
  int exp = 0;
  int expToNextLevel = 100;
  int killCount = 0;

  void levelUp() {

  }

  void atttackMonster() {

  }

  void defend() {

  }

  void showStatus() {

  }
}

class Monster {
  String name = "";
  int hp = 100;
  int atk = 10;
  int def = 5;
  int level = 1;
  int exp = 0;

  attackCharacter(Character character) {

  }

  showStatus() {

  }
}

void main(List<String> arguments) {

  final game = Game();
  game.startGame();
}
