//Version2 now has layer support. Many thnx again to grauw for writing the code I couldn't understand and helping me out.
//Version3 sorts the x entries in the object layer. Currently only 1!!! object layer is supported
//version3.1 supports sjasmplus fully
//This one is specially made to output 16 bit stg' s

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <cstdio>
#include <iomanip>
#include <vector>
using namespace std;

void process(istream& in, ostream& out)
{
    //vector<string> layers;
    vector<vector<int>> layers;

	string line;
	while (getline(in, line))
	{
		if (line.find("<data ") != string::npos)
		{
			//ostringstream sout;
            vector<int> layer;
            
			while (getline(in, line) && line.find("</data>") == string::npos)
			{
				string value;
				istringstream sin(line);
				while (getline(sin, value, ','))
				{
					if (!value.empty())
					{
					//	sout << static_cast<char>(stoi(value) - 1);
                        layer.push_back(stoi(value));
					}
				}
			}

			//layers.push_back(sout.str());
			layers.push_back(layer);
		}
	}

	//error detection in case of faulty tmx file
	if (!layers.size())
    {
        cerr << "ERROR: Cannot find TMX,CSV data layers: Your TMX file is either in the wrong format, corrupt or missing.";
        return;
    }
    
	

    
for (int i = 0; i < layers[0].size(); i++)
	{
        char lsb(0); 
        char msb(0);
    //for (string layer : layers) 
        for (vector<int> layer : layers)
        { 
            if (layer[i]) 
            { 
                lsb = layer[i]; 
                msb = layer[i] >> 8; 
            } 
            
        } 
        out << lsb << msb;	

    }
	

}





int main(int argc, char* argv[])
{ 
    
 
    
  if (argc < 2)
  {
    cerr << "Kickass TMX (CSV left down) to raw stg map converter V3.1, use -h for help\nUsage: " << argv[0] << " in.tmx out.stg\n";
    return 1;
  }

  if (argc == 2 && argc != 4)
  {
   
    std::string arg1(argv[1]);   
      
    if (arg1.compare("-h") == 0)
    {
        cerr << "Kickass TMX (CSV left down) to raw stg map converter by Daemos and Grauw V3.1\nUsage: " << argv[0] << " in.tmx out.stg\n\n\nCommands:\n-h = display this help tekst and exit\n\nNo command will generate a working stg mapfile from the tmx file\n\nPlease note that the TMX file must be saved in the CSV form!\n";
        return 0;
    }

        if (arg1.compare("-l") == 0)
        {
            return 0;
        }
            
            
    ifstream fin;
    fin.open(argv[1]);

    process(fin, cout);

    fin.close();
    
    cerr << "\n"; //trow whiteline to make output look nice
    
        return 0;
    
  }
  else if (argc == 3)  
  {

    std::string arg1(argv[1]);
         
     if (arg1.compare("-l") == 0) 
    
    {
        
 //   ifstream fin;
 //   fin.open(argv[2]);

 //   processl(fin, cout);

 //   fin.close();
    
 //   cerr << "\n"; //trow whiteline to make output look nice        
    
    return 0;
    
    }
  
      if (arg1.compare("-h") == 0)
    {
        cerr << "Kickass TMX (CSV left down) to raw stg map converter by Daemos and Grauw\nUsage: " << argv[0] << " in.tmx out.stg or out.asm if using the -l command\n\n\nCommands:\n-h = display this help tekst and exit\n-l = extract and generate objectslist from the tmx objects layer\nNo command will generate a working stg mapfile from the tmx file\n\nPlease note that the TMX file must be saved in the CSV form!\n";
        return 0;
    }
  
  ifstream fin;
  ofstream fout;
  fin.open(argv[1]);
  fout.open(argv[2]);

  process(fin, fout);

  fin.close();
  fout.close();

  return 0;
  }
  else if (argc == 4)
  {
    std::string arg1(argv[1]);
      
    
        if (arg1.compare("-h") == 0)
    {
        cerr << "Kickass TMX (CSV left down) to raw stg map converter by Daemos and Grauw\nUsage: " << argv[0] << " in.tmx out.stg or out.asm if using the -l command\n\n\nCommands:\n-h = display this help tekst and exit\n-l = extract and generate objectslist from the tmx objects layer\nNo command will generate a working stg mapfile from the tmx file\n\nPlease note that the TMX file must be saved in the CSV form!\n";
        return 0;
    }
    
     if (arg1.compare("-l") == 0) 
    
    {    
 // ifstream fin;
 // ofstream fout;
 // fin.open(argv[2]);
 // fout.open(argv[3]);

 // processl(fin, fout);

 // fin.close();
 // fout.close();

  return 0;
    }

     
  }  
      
  
}
