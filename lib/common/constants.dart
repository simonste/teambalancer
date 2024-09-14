enum Sport { football, floorball, basketball }

enum Skill { tactical, physical, technical, form }

enum Tactics { defense, neutral, offense }

class Constants {
  static double weightMin = 1;
  static double weightMax = 3;
  static int weightDivisions = (weightMax - weightMin).toInt();
  static int defaultWeight = 1;

  static double skillMin = 1;
  static double skillMax = 5;
  static double defaultSkill = (skillMin + skillMax) / 2;
  static int skillDivisions = (skillMax - skillMin).toInt();

  static int maxGroups = 4;
}
