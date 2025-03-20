import 'dart:convert';
import 'dart:io';
import 'dart:math';

class Game {
  Character character = Character(); // 캐릭터
  List<Monster> monsters = [];
  int killCountMob = 3; // 게임종료 카운트
  Monster selectedMonster = Monster(); // 선택된 몬스터=랜덤으로 골라진

  // 사용자로부터 캐릭터 이름 입력받기
  RegExp nameRegExp = RegExp(r'^[a-zA-Z가-힣]+$');
  

  void startGame() {

    while (true) { // 이름받기
    stdout.write("캐릭터 이름 입력 (영문 또는 한글만 허용): \n");
    character.name = stdin.readLineSync(encoding: systemEncoding) ?? "Player"; // 인코딩 설정 추가?
    if (nameRegExp.hasMatch(character.name)) {
      break;
    } else {
      print("잘못된 입력입니다. 영문 또는 한글만 입력해주세요.");
      }
    }

  print("환영합니다, ${character.name}!");
  
    // 캐릭터 스탯 읽기
    final characterStats = File('data/characters.txt').readAsStringSync().split(',');
    if (characterStats.length == 3) { // HP, ATK, DEF 체크
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




    // 초기화 완료후 게임시작
    //작성필요
    while(true){
      battle();

      if(character.killCount == killCountMob){
        print("몬스터를 모두 처치하여 게임을 종료합니다.");
        break;
      }

    }
  }

  void battle() {

    // 몬스터 랜덤 생성
    selectedMonster = getRandomMonster();
    // 전투 시작
    while (true) {
      // 캐릭터가 몬스터 공격
      character.attackMonster(selectedMonster);

      // 몬스터가 캐릭터 공격
      selectedMonster.attackCharacter(character);

      // 전투 종료 체크
      if (character.hp <= 0) {
        print("전투에서 패배했습니다.");
        break;
      } else if (monsters[0].hp <= 0) {
        print("전투에서 승리했습니다.");
        character.killCount++;
        }
      print("다음 몬스터와 대결하시겠습니까? y/n");
      final next = stdin.readLineSync(encoding: systemEncoding);
      if (next != 'y') {
        break;
      }
      
    }
  } 
  

  Monster getRandomMonster() {
    int randomIndex = 0;
    Monster selectMonster = monsters[randomIndex];
    if (monsters.length > 0) {
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
    monster.hp -= max(0, atk - monster.def);
    monster.showStatus();
  }

  void defend(Monster monster) {
    hp = hp - monster.atk;
    showStatus();
  }

  void showStatus() {
    print("캐릭터: $name, HP: $hp, 공격력: $atk, 방어력: $def, 처치한 몬스터 수: $killCount");
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
    character.hp -= max(0, atk - character.def);
    character.showStatus();
  }

  showStatus() {
    print("몬스터: $name, HP: $hp, 공격력: $atk, 방어력: $def, 레벨: $level, 경험치: $exp");
  }
}

void main(List<String> arguments) {

  final game = Game();
  game.startGame();
}
