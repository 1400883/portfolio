#include <list>
#include <fstream>
#include <iostream>
using namespace std;
/////////////////////////
char companyFile[] = "companies.dat";
// char articleFile[] = "article.dat";
/////////////////////////
// #define DEBUG
/////////////////////////
list< list<string> > companyList;
/////////////////////////
extern void ParseStdin(list< list<string> >);
/////////////////////////
int main(int argc, char **argv) {
  char cLine[2048];
  string line;
  ifstream fs;
  int pos;

  // Get company names
  fs.open(companyFile);
  do {
    list<string> companyNameList;
    fs.getline(cLine, sizeof(cLine));
    line = cLine;
    while (pos = line.find("\t")) {
      companyNameList.push_back(
        line.substr(0, pos));
      #ifdef DEBUG
      cout << "New company name found: " << companyNameList.back() << "\n";
      #endif
      // Is last company?
      if (pos == string::npos) {
        // Add new company in the list
        companyList.push_back(companyNameList);
        #ifdef DEBUG
        cout << "New company complete with " << companyNameList.size() << " names.\n";
        #endif
        companyNameList.clear();
        break;
      }
      line = line.substr(pos + 1);
    }
  } while (fs.good());
  fs.close();
  // Process the article
  ParseStdin(companyList);
  return 0;
}