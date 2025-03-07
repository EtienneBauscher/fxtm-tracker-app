abstract class ForexCategoriesUtilityContract {
  Map<String, List<List<String>>> get groups;
  void categorizeSymbols(List<String> symbols);
  void splitIntoGroups(int maxSize);
}
