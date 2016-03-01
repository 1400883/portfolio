/*
  Copyright (c) 2015 Tuomas Keinänen
*/
  
#include <list>
// #include <utility>
#include <map>
#include <cctype>
#include <iostream>
#include <sstream>
using namespace std;
/////////////////////////
// SETUP VARIABLES
/////////////////////////
string punctuation[] = {
  ",", ".", "(", ")", "?", "!", "'s", "'", "\"" 
};
string wordsExcludedFromCount[] = {
  "a", "an", "the", "and", "or", "but"
};
// Gets rid of dashes such as "Intel-based" 
// (replacement: "Intel based"), where 
// "Intel" would otherwise remain undetected.
// However, this will also replace dashes in 
// company names, such as Hewlett-Packard.
bool replaceDashesWithSpaces = true;
// Should "[X]", where X is anything,
// be removed from the text before matching?
bool wantSquareBracketReferencesRemoved = true;
// How many decimals should be displayed 
// in the resulting relevance percentage value?
int resultDecimalPlaces = 2;
/////////////////////////
// #define DEBUG
/////////////////////////
bool IsExcludedWord(string&);
void RemovePunctuation(string&);
void RemoveSquareBrackets(string&);
void RemoveExtraSpaces(string&);
void ReplaceDashesWithSpaces(string& s);
/////////////////////////
void ParseStdin(list< list<string> > companyList) {
  char cLine[2048];
  string line;
  int pos;

  // Parse stdin
  list< list<string> >::iterator iCompany;
  list<string>::iterator iCompanyName;
  // Storage for company primary names
  string primaryNames[companyList.size()];
  // Storage for the name count found for each company
  int foundNameCount[companyList.size()];
  // Initialize company name counts
  for (int i = 0; i < sizeof(foundNameCount) / sizeof(int); ++i) {
    foundNameCount[i] = 0;
  }
  // Initialize article word counter
  int numWordsTotal = 0;
  // Process text line by line
  do {
    cin.getline(cLine, sizeof(cLine));
    // fs.getline(cLine, sizeof(cLine));
    line = cLine;
    // Check if the period denoting the end has been reached
    if (line == ".") {
      break;
    }
    RemovePunctuation(line);
    if (replaceDashesWithSpaces)
      ReplaceDashesWithSpaces(line);
    // Convert tabs to spaces. Then remove leading,
    // trailing and multiple successive spaces.
    RemoveExtraSpaces(line);
    // Skip empty lines
    if (line == "")
      continue;
    if (wantSquareBracketReferencesRemoved)
      RemoveSquareBrackets(line);

    bool isWordCountDone = false;
    list< pair<int, int> > wordMatchLocations;
    list< pair<int, int > >::iterator iMatchLoc;
    #ifdef DEBUG
    cout << "\n" << line << "\n"; 
    #endif
    // Process each company
    int iCompanyInt;
    for ( iCompany = companyList.begin(); 
          iCompany != companyList.end(); 
        ++iCompany) {
      int foundCount = 0;
      // The index of the company
      iCompanyInt = distance(companyList.begin(), iCompany);
      // Init match location variable
      wordMatchLocations.clear();
      // Process each company name
      for ( iCompanyName = iCompany->begin(); 
            iCompanyName != iCompany->end(); 
          ++iCompanyName) {
        // Get Nth company name for the current company
        string companyName = *iCompanyName;
        // Is the first name for the company being processed?
        if (!distance(iCompany->begin(), iCompanyName)) {
          // Store primary name
          primaryNames[iCompanyInt] = companyName;
          #ifdef DEBUG
          cout << "\nprimaryName: " << primaryNames[iCompanyInt] << "\n";
          #endif
        }
        // Remove punctuation
        RemovePunctuation(companyName);
        // Replace dashes with spaces
        if (replaceDashesWithSpaces)
          ReplaceDashesWithSpaces(companyName);
        // Convert tabs to spaces. Then remove leading,
        // trailing and multiple successive spaces.
        RemoveExtraSpaces(companyName);
        #ifdef DEBUG
        cout << "\ncompanyName: " << companyName;
        #endif
        string lineCopy = line;
        // Calculate how many times the Nth company name is found
        // in the line of text currently iterated
        while ((pos = lineCopy.find(companyName)) != string::npos) {
          ++foundCount;
          // Store the location of the company name found
          pair<int, int> location(pos, companyName.length());
          wordMatchLocations.push_back(location);
          // Remove text up to the point from where the 
          // company name was found plus the company name.
          lineCopy = lineCopy.substr(pos + companyName.length());
          #ifdef DEBUG
          cout << "\n" << companyName << " found";
          #endif
        }
        // Count words for the current line only once
        if (!isWordCountDone) {
          pos = 0;
          int posBefore = 0;
          while (pos != string::npos) {
            pos = line.substr(posBefore).find(" ");
            string word = line.substr(posBefore, pos);
            // See if a company name was found in the line
            if (foundCount) {
              // See if the word belongs to a company name found in the line
              for ( iMatchLoc = wordMatchLocations.begin(); 
                    iMatchLoc != wordMatchLocations.end(); 
                  ++iMatchLoc) {
                if (posBefore < iMatchLoc->first || 
                    posBefore > iMatchLoc->second) {
                  // Word is not a part of the company name.
                  // See if the word is one of the words excluded from count.
                  if (!IsExcludedWord(word)) {
                    // It's a good word => increase the count
                    ++numWordsTotal;
                  }
                }
                else {
                  // Word is part of the company name 
                  // and will thus increase the count
                  ++numWordsTotal;
                }
              }
            }
            else {
              // Company name not found in the line.
              // Increase count if the word does not belong
              // to the list of excluded words
              if (!IsExcludedWord(word)) {
                ++numWordsTotal;
              }
            }
            #ifdef DEBUG
            cout << "\nword: " << word;
            #endif
            posBefore += pos + 1;
          }
          #ifdef DEBUG
          cout << "\n";
          #endif
          isWordCountDone = true;
        }
      }
      foundNameCount[iCompanyInt] += foundCount;
      #ifdef DEBUG
      cout 
        << "\n" << primaryNames[iCompanyInt] << " found total of " 
        << foundNameCount[iCompanyInt] << " times\n";
      #endif
    }
    #ifdef DEBUG
    cout << "\nnumWordsTotal: " << numWordsTotal << "\n";
    #endif
  } while (cin.good());

  // Output results
  for ( iCompany = companyList.begin(); 
        iCompany != companyList.end(); 
      ++iCompany) {
    int iCompanyInt = distance(companyList.begin(), iCompany);
    float relevance = 
      float(foundNameCount[iCompanyInt]) / numWordsTotal * 100;
    stringstream ss;
    ss << (int)relevance;
    cout.precision(
      ss.str().length() + resultDecimalPlaces - ((int)relevance ? 0 : 1)
    );
    cout 
    << primaryNames[iCompanyInt] 
    << " relevance: " << relevance << " \%";
    if (distance(iCompany, companyList.end()) > 1)
      cout << "\n";
  }
}

void RemoveExtraSpaces(string& line) {
  int pos;
  // Convert tabs to spaces
  while ((pos = line.find("\t")) != string::npos) {
    line.replace(pos, 1, " ");
    #ifdef DEBUG
    cout << "\nTab\n";
    #endif
  }
  // Leading spaces
  while (line[0] == ' ') {
    line.erase(0, 1);
    #ifdef DEBUG
    cout << "\nLeading space\n";
    #endif
  }
  // Trailing spaces
  while (line[line.length() - 1] == ' ') {
    line.erase(line.length() - 1, 1);
    #ifdef DEBUG
    cout << "\nTrailing space\n";
    #endif
  }
  // Successive spaces
  while ((pos = line.find("  ")) != string::npos) {
    line.erase(pos, 1);
    #ifdef DEBUG
    cout << "\nSuccessive spaces\n";
    #endif
  }
}

bool IsExcludedWord(string& word) {
  int excWordArraySize = 
    sizeof(wordsExcludedFromCount) / 
    sizeof(*wordsExcludedFromCount);
  for (int iExcWord = 0; iExcWord < excWordArraySize; iExcWord++) {
    // Match both cases
    string singleChar;
    singleChar = toupper(word[0]);
    string titleCasedWord = singleChar + word.substr(1);
    singleChar = tolower(word[0]);
    string lowerCasedWord = singleChar + word.substr(1);
    if (titleCasedWord == wordsExcludedFromCount[iExcWord] ||
        lowerCasedWord == wordsExcludedFromCount[iExcWord]) {
      // Word should be excluded from the count
      return true;
    }
  }
  return false;
}

void RemoveSquareBrackets(string& s) {
  int posBegin, posEnd;
  while ((posBegin = s.find("[")) != string::npos) {
    if ((posEnd = s.substr(posBegin + 1).find("]")) != string::npos) {
      s.erase(posBegin, posEnd + 2);
    }
  }
}

void ReplaceDashesWithSpaces(string& s) {
  int pos;
  while ((pos = s.find("-")) != string::npos) {
    s.replace(pos, 1, " ");
    #ifdef DEBUG
    cout << "\nDash\n";
    #endif
  }
}

void RemovePunctuation(string& s) {
  int pos;
  for (int i = 0; i < sizeof(punctuation) / sizeof(*punctuation); ++i) {
    while ((pos = s.find(punctuation[i])) != string::npos) {
      s.erase(pos, punctuation[i].length());
    }
  }
}