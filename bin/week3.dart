import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

class Game {
  Character character = Character(); // 캐릭터
  List<Monster> monsters = [];
  int killCountMob = 3; // 게임종료 카운트
  Monster selectedMonster = Monster(); // 선택된 몬스터=랜덤으로 골라진
  int battleResult = 2; // 전투결과 0:패배, 1:승리, 2:진행중
  // 사용자로부터 캐릭터 이름 입력받기
  RegExp nameRegExp = RegExp(r'^[a-zA-Z가-힣]+$');

  void startGame() {
    while (true) {
      // 이름받기
      stdout.write("캐릭터 이름 입력 (영문 또는 한글만 허용):");
      character.name =
          stdin.readLineSync(encoding: systemEncoding) ??
          "Player"; // 인코딩 설정 추가?
      if (nameRegExp.hasMatch(character.name)) {
        break;
      } else {
        print("잘못된 입력입니다. 영문 또는 한글만 입력해주세요.\n\n");
      }
    }

    // 캐릭터 스탯 읽기
    final characterStats = File(
      'data/characters.txt',
    ).readAsStringSync().split(',');
    if (characterStats.length == 3) {
      // HP, ATK, DEF 체크

      character.hp = int.parse(characterStats[0]); // // 3칸짜리 리스트에 저장
      character.atk = int.parse(characterStats[1]);
      character.def = int.parse(characterStats[2]);
    }

    // 몬스터 스탯 읽기
    final monsterLines = File('data/monsters.txt').readAsLinesSync();
    for (var line in monsterLines) {
      final monsterStats = line.split(',');
      if (monsterStats.length == 3) {
        final monster =
            Monster() // 3칸짜리 리스트에 저장
              ..name = monsterStats[0]
              ..hp = int.parse(monsterStats[1])
              ..atk = int.parse(monsterStats[2]);
        monsters.add(monster);
      }
    }

    print("------------------게임 시작합니다!--------------");
    character.showStatus();
    // 초기화 완료후 게임시작
    while (true) {
      battle();

      if (battleResult == 0) {
        print("패배 종료");
        break;
      }
      if (character.killCount != killCountMob) {
        print("다음 몬스터와 대결하시겠습니까? y/n");
        String nextBattle = stdin.readLineSync() ?? "y";
        if (nextBattle == "y") {
          continue;
        } else {
          print("비희망 게임 종료");
          break;
        }
      }

      if (character.killCount == killCountMob) {
        print("승리 종료");
        break;
      }
    }
  }

  void battle() {
    // 몬스터 랜덤 생성
    Random random = Random();
    selectedMonster = getRandomMonster();
    selectedMonster.atk =
        character.def + random.nextInt(selectedMonster.atk - character.def + 1);

    print("\n새로운 몬스터가 나타났습니다!");
    selectedMonster.showStatus();
    print("\n");
    int fightType = 0;
    int battleResult = 2;
    // 전투 시작
    while (!(battleResult == 0 || battleResult == 1)) {
      // 캐릭터가 몬스터 공격or방어 선택
      if (selectedMonster.hp > 0) {
        while (true) {
          print("${character.name}의 턴.");
          stdout.write("행동을 선택하세요 (1: 공격, 2: 방어): ");

          fightType = int.tryParse(stdin.readLineSync() ?? "1") ?? 1;

          if (fightType == 1) {
            character.attackMonster(selectedMonster); // 공격
            break;
          } else if (fightType == 2) {
            // 방어
            character.defend(selectedMonster);
            break;
          } else {
            print("잘못된 입력입니다. 1 또는 2를 입력해주세요.");
          }
        }
        // 몬스터가 캐릭터 공격
        print("${selectedMonster.name}의 턴");
        selectedMonster.attackCharacter(character);
        character.showStatus();
        selectedMonster.showStatus();
        print("\n");
        // 전투 종료 체크
        if (character.hp <= 0) {
          // 유저패
          print("전투에서 패배했습니다.");
          battleResult = 0;
        } else if (selectedMonster.hp <= 0) {
          // 유저승
          print("전투에서 승리했습니다.");
          character.killCount++;

          monsters.remove(selectedMonster); // 패배한 몬스터를 리스트에서 삭제
          battleResult = 1;
        }
      }
    }
  }

  Monster getRandomMonster() {
    int randomIndex = 0;
    Monster selectMonster = monsters[randomIndex];
    if (monsters.isNotEmpty) {
      randomIndex = Random().nextInt(monsters.length);
      selectMonster = monsters[randomIndex];
    }
    return selectMonster;
  }
}

class Character {
  String name = "";
  int hp = 100;
  int atk = 10;
  int def = 5;
  int killCount = 0;

  void attackMonster(Monster monster) {
    // 몬스터에게 데미지를 입힘
    monster.hp = monster.hp - max(0, atk - monster.def);
    print("$name이 공격 자세를 취해 ${max(0, atk - monster.def)}만큼 데미지 줌\n");
  }

  void defend(Monster monster) {
    hp = hp + max(0, monster.atk - def);
    print("$name이 방어 자세를 취해 ${max(0, monster.atk - def)}만큼 체력 획득\n");
  }

  void showStatus() {
    print("캐릭터: $name, HP: $hp, 공격력: $atk, 방어력: $def, 처치한 몬스터 수: $killCount");
  }
}

class Monster {
  String name = "";
  int hp = 0;
  int atk = 0;
  int def = 0;

  attackCharacter(Character character) {
    character.hp -= max(0, atk - character.def);
    print(
      "$name이(가) ${character.name}을(를) 공격하여 ${max(0, atk - character.def)}만큼 데미지 줌",
    );
  }

  showStatus() {
    print("몬스터: $name, HP: $hp, 공격력: $atk, 방어력: $def");
  }
}

void main(List<String> arguments) {
  final game = Game();
  game.startGame();
}
