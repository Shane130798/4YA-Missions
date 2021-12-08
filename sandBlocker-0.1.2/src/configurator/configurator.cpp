#include <fstream>
#include <iostream>
#include <iomanip> //setw(x)
#include <string>

#include "json.hpp" //json for modern c++: https://github.com/nlohmann/json/releases/tag/v3.10.1
#include "database.hpp"

using json = nlohmann::json;

bool DEBUG = false;

//SYS FLAGS
bool TERM = false;

std::string PROCESS;
std::string PATH;
std::string MISSION;

json REF;


//REFERENCE CALLS
bool changeAirfieldCoalition(std::string airfield, std::string newCoalition);
bool addAirfield(std::string airfield=" ", std::string currentCoalition=" ");
void delAirfield(std::string airfield);

bool addFarp(std::string farp, std::string currentCoalition);
bool changeFarpCoalition(std::string farp, std::string newCoalition);
void delFarp(std::string farp);

void printAirfield(std::string airfield=" ", bool printAll=false);
void printDCS_airfields(std::string DCS_map);

void editPrompt(void);
void newPrompt(void);
void printPrompt(void);

//MISC
void shutdown(bool isEdit=false)
{
	std::cout<<"\nSYSTEM: saving to "+PATH+"\\"+MISSION+"_SBconfig.json"<<std::endl;
	
	if(isEdit)
	{
		std::ofstream cfg(PATH);
		if(cfg.is_open())
		{
			cfg << std::setw(4) << REF << std::endl;
			cfg.close();
		}
	}
	else
	{
		std::ofstream cfg(PATH+"\\"+MISSION+"_SBconfig.json");
		if(cfg.is_open())
		{
			cfg << std::setw(4) << REF << std::endl;
			cfg.close();
		}
	}
	return;
}

std::string caps(std::string str)
{
	for(int i=0; i<str.size(); i++)
		str[i] = toupper(str[i]);

	return str;
}

bool scanVar(std::string var=" ", std::string mode=" ")
{
	if(mode == " ")
	{
		std::cout<<"\nERROR: scanVar => [mode] > expected a mode, got none..."<<std::endl;
		return true;
	}
	else if(var == " ")
	{
		std::cout<<"\nERROR: scanVar => [var] > expected a variable, got none..."<<std::endl;
		return true;
	}
	else
	{
		if(caps(mode) == "COALITION")
		{
			if((caps(var) == "BLUE") || (caps(var) == "RED") || (caps(var) == "NEUTRAL"))
			{
				return true;
			}
			return false;
		}

		else if(caps(mode) == "DB_AIRFIELDS")
		{
			//DEBUG
			//std::cout<<"\nDEBUG: scanVar DB_AIRFIELDS activated!"<<std::endl;

			for(const auto& [map, airfields] : DCS)
			{
				for(const auto& [airfield, coalitions] : airfields)
				{
					if(caps(var) == caps(airfield))
					{
						return true;
					}
				}
			}
			return false;
		}

		else if(caps(mode) == "REF_NAME")
		{
			//DEBUG
			//std::cout<<"\nDEBUG: scanVar REF_NAME activated!"<<std::endl;

			if(REF["BLOCKER"][caps(var)] != nullptr)
			{
				//DEBUG
				//std::cout<<"\nDEBUG: checkVar REF_NAME > this airport exists!"<<std::endl;

				return true;
			}
			else
			{
				//DEBUG
				//std::cout<<"\nDEBUG: checkVar REF_NAME > this airport does not exist yet!"<<std::endl;

				return false;
			}
		}

		else if(caps(mode) == "REF_FARP")
		{
			if(REF["BLOCKER"][caps(var)] != nullptr)
			{
				if(caps(var).find("FARP-"))
				{
					return true;
				}
				else
				{
					std::cout<<"\nERROR: scanVar REF_FARP > var is not a farp!"<<std::endl;
					return true;
				}
			}
			else
			{
				return false;
			}
		}
		else
		{
			std::cout<<"\nERROR: scanVar => invalid mode!"<<std::endl;
			return true;
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//EXEC
int main(int argc, char *argv[])
{
	if(DEBUG)
	{
		std::cout<<"argc: "<<argc<<std::endl;
		for(int i=0; i<argc; i++)
		{
			std::cout<<"*argv["+std::to_string(i+1)+"]: "<<argv[i]<<std::endl;
		}
	}
	
	//some quick sanity / input checking...
	if(argc > 3)
	{
		std::cout<<"\nERROR: this program takes 2 arguments but "<<argc-1<<" were given..."<<std::endl;
		return 0;
	}
	
	PROCESS = argv[1];
	PATH 	= argv[2];
	
	if((caps(PROCESS) == "-EDIT" || caps(PROCESS) == "-NEW") && argc < 3)
	{
		std::cout<<"\nERROR: this argument takes a 2nd argument! [PATH],\nuse 'HELP' or '?' to recieve help for this program\n"<<std::endl;
		return 0;
	}

	if(DEBUG)
	{
		//DEBUG
		std::cout<<"DEBUG PROCESS: "<<PROCESS<<std::endl;
		std::cout<<"DEBUG PATH: "<<PATH<<std::endl;
		std::cout<<"DEBUG MISSION: "<<MISSION<<std::endl;
	}
	
	//execute
	if((caps(PROCESS) == "HELP") || (caps(PROCESS) == "?"))
	{
		std::cout<<"\n[CONFIGURATOR HELP]\n"<<std::endl;
		std::cout<<"ABOUT:\nThis configurator is a tool which allows you to setup a SBconfig file with relative ease.\nit also allows the user to edit already existing config files!\n"<<std::endl;
		std::cout<<"USAGE:\nconfigurator.exe -command -path*\n\n*required for all commands marked with [!]\n"<<std::endl;
		std::cout<<"CMD:\nhelp, ?     > displays this message\n"<<std::endl;
		std::cout<<"[!] -new    > starts the configurator to configure a new config file to the specified path\n"<<std::endl;
		std::cout<<"[!] -edit   > starts the configurator to edit the config file given at the specified path\n"<<std::endl;
		std::cout<<"[!] -print  > prints the config file at the specified path\n"<<std::endl;

		return 0;
	}
	
	else
	{
		if(caps(PROCESS) == "-NEW")
		{
			std::cout<<"\n\n\nPLEASE ENTER THE EXACT MISSION NAME\n\n> ";
			std::cin>>MISSION;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return -1;
			}
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			while(!TERM)
			{
				newPrompt();
			}

			shutdown();
			return 0;
		}
		
		if(caps(PROCESS) == "-EDIT")
		{

			while(!TERM)
			{
				editPrompt();
			}

			shutdown(true);
			return 0;
		}
		
		if(caps(PROCESS) == "-PRINT")
		{
			while(!TERM)
			{
				printPrompt();
			}

			shutdown();
			return 0;	
		}	
	}
}

//CONFIG
//airfield
bool changeAirfieldCoalition(std::string airfield, std::string newCoalition)
{
	if(scanVar(caps(airfield), "DB_AIRFIELDS"))
	{
		if(scanVar(caps(airfield), "REF_NAME"))
		{
			if(scanVar(caps(newCoalition), "COALITION"))
			{
				REF["BLOCKER"][caps(airfield)] = caps(newCoalition);
				return true;
			}
			else
			{
				std::cout<<"\nERROR: this coalition does not exist!"<<std::endl;
				return false;
			}
		}
		else
		{
			std::cout<<"\nERROR: this airport doesn't exist yet, do you want to make one? y/n\n\n> ";
			char arg;
			std::cin>>arg;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return false;
			}
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			if(toupper(arg) == 'Y')
			{
				addAirfield(airfield, newCoalition);
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	else
	{
		std::cout<<"\nERROR: invalid airfield!"<<std::endl;
		return false;
	}
}

bool addAirfield(std::string airfield, std::string currentCoalition)
{
	if(scanVar(caps(airfield), "DB_AIRFIELDS"))
	{
		if(DEBUG)
		{
			std::cout<<"\nDEBUG: valid from database"<<std::endl;
		}

		if(!scanVar(caps(airfield), "REF_NAME"))
		{
			if(DEBUG)
			{
				std::cout<<"\nDEBUG: scanVar outcome > airfield does not exist yet"<<std::endl;
			}

			if(scanVar(caps(currentCoalition), "COALITION"))
			{
				if(DEBUG)
				{
					std::cout<<"\nDEBUG: add this to the blocker"<<std::endl;
				}
				
				REF["BLOCKER"][caps(airfield)] = caps(currentCoalition);
				return true;
			}
			else
			{
				std::cout<<"\nERROR: invalid coalition"<<std::endl;
				return false;
			}
		}
		else
		{
			std::cout<<"\nERROR: this airfield exists! would you like to overwrite it? y/n\n\n> ";
			char arg;
			std::cin>>arg;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return false;
			}
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			if(toupper(arg) == 'Y')
			{
				changeAirfieldCoalition(airfield, currentCoalition);
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	else
	{
		std::cout<<"\nERROR: invalid airfield!"<<std::endl;
		return false;
	}
	return false;
}

void delAirfield(std::string airfield)
{
	if(scanVar(caps(airfield), "REF_NAME"))
	{
		REF["BLOCKER"].erase(caps(airfield));
		return;
	}
	else
	{
		std::cout<<"\nEXCEPTION: this airfield doesn't exist, that was easy!"<<std::endl;
		return;
	}
}

//farp
bool addFarp(std::string farp, std::string currentCoalition)
{
	//FARP is defined with 'FARP-blablablablablabla'

	if(DEBUG)
	{
		std::cout<<"\nDEBUG: addFarp - farp > "<<farp<<std::endl;
		std::cout<<"DEBUG: addFarp - currentCoalition > "<<currentCoalition<<std::endl;
	}

	if(farp.find("FARP-") == std::string::npos)
	{
		if(DEBUG)
		{
			std::cout<<"\nDEBUG: adding 'FARP-' to "+farp<<std::endl;
		}

		farp = "FARP-"+caps(farp);
	}

	if(!scanVar(caps(farp), "REF_FARP"))
	{
		if(scanVar(caps(currentCoalition), "COALITION"))
		{
			REF["BLOCKER"][caps(farp)] = caps(currentCoalition);
			return true;
		}
		else
		{
			std::cout<<"\nERROR: invalid coalition!"<<std::endl;
			return false;
		}
	}
	else
	{
		std::cout<<"\nERROR: this farp exists! would you like to overwrite it? y/n\n\n> ";
		char arg;
		std::cin>>arg;
		if(!std::cin)
		{
			std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
		
			return false;
		}
		std::cin.clear();
		std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

		if(std::toupper(arg) == 'Y')
		{
			changeFarpCoalition(farp, currentCoalition);
			return true;
		}
		else
		{
			return false;
		}
	}
}

bool changeFarpCoalition(std::string farp, std::string newCoalition)
{
	if(DEBUG)
	{
		std::cout<<"\nDEBUG: changeFarpCoalition - farp > "<<farp<<std::endl;
		std::cout<<"DEBUG: changeFarpCoalition - newCoalition > "<<newCoalition<<std::endl;
	}
	
	if(farp.find("FARP-") == std::string::npos)
	{
		farp = "FARP-"+caps(farp);
	}

	if(scanVar(caps(farp), "REF_NAME"))
	{
		if(scanVar(caps(newCoalition), "COALITION"))
		{
			REF["BLOCKER"][caps(farp)] = caps(newCoalition);
			return true;
		}
		else
		{
			std::cout<<"\nERROR: invalid coalition!"<<std::endl;
			return false;
		}
	}
	else
	{
		std::cout<<"\nERROR: this farp doesn't exists! would you like to make it? y/n\n\n> ";
		char arg;
		std::cin>>arg;
		if(!std::cin)
		{
			std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
		
			return false;
		}
		std::cin.clear();
		std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

		if(std::toupper(arg) == 'Y')
		{
			addFarp(farp, newCoalition);
			return true;
		}
		else
		{
			return false;
		}
	}
}

void delFarp(std::string farp)
{
	if(DEBUG)
	{
		std::cout<<"\nDEBUG: delFarp - farp > "<<farp<<std::endl;
	}

	if(farp.find("FARP-") == std::string::npos)
	{
		farp = "FARP-"+caps(farp);
	}

	if(scanVar(caps(farp), "REF_NAME"))
	{
		REF["BLOCKER"].erase(caps(farp));
		return;
	}
	else
	{
		std::cout<<"\nEXCEPTION: this farp doesn't exist, that was easy!"<<std::endl;
		return;
	}
}

//PRINT
void printAirfield(std::string airfield, bool printAll)
{
	if(printAll)
	{
		std::cout<<"\n\n\n=======================================\n"<<std::endl;
		std::cout<<std::setw(4)<<REF["BLOCKER"]<<std::endl;		//this works appearantly :D
		std::cout<<"\n\n\n=======================================\n"<<std::endl;
		return;
	}
	else
	{
		if(airfield != " ")
		{
			if(scanVar(caps(airfield), "REF_NAME"))
			{
				std::cout<<"\n\n\nairfield: "<<caps(airfield)<<", coalition: "<<REF["BLOCKER"][caps(airfield)]<<"\n"<<std::endl;
				return;
			}
			else
			{
				std::cout<<"\nERROR: this airfield does not exist!"<<std::endl;
				return;
			}
		}
		else
		{
			std::cout<<"\nERROR: printAirfield() => expected airfield, got null"<<std::endl;
			return;
		}	
	}
}

void printDCS_airfields(std::string DCS_map)
{
	std::cout<<std::string(100, '=')<<std::endl;
	  
	for(const auto& [airfield, coalition_map] : DCS[caps(DCS_map)])
	{
		std::cout<<airfield<<std::endl;
	}

	std::cout<<std::string(100, '=')<<std::endl;
	return;
}


//PROMPT
void editPrompt(void)
{
	std::ifstream cfg(PATH);
	if(cfg.is_open())
	{
		REF << cfg;
		cfg.close();
	}
	else
	{
		std::cout<<"\nERROR: make sure you use the absolute path to the config file!"<<std::endl;
		TERM = true;
		terminate();
		return;
	}
	
	std::cout<<"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"<<std::endl;
	bool done = false;
	while(!done)
	{
		std::cout<<"\n\nWelcome to the configurator, what would you like to do?\n[AF-add, AF-del, AF-change / FARP-add, FARP-del, FARP-change / print-cur, print-dcs, term]"<<std::endl;
		std::cout<<"\n> ";	//feverdream esque programming, aaaaa!
		std::string arg;
		std::cin>>arg;
		if(!std::cin)
		{
			std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
			return;
		}
		//DEBUG
		std::cin.clear();
		std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

		if(caps(arg) == "TERM")
		{
			TERM = true;
			return;
		}
		else if(caps(arg) == "PRINT-CUR")
		{
			printAirfield(" ", true);
		}
		else if(caps(arg) == "PRINT-DCS")
		{
			std::string map;
			std::cout<<"\nplease enter for which map you'd like to print all airbases\n\n> ";
			std::cin>>map;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			printDCS_airfields(map);
		}
		
		else if(caps(arg) == "AF-ADD")
		{
			std::string airfield, coalition;
			std::cout<<"\nplease enter the airfield and the coalition seperated with [enter]..."<<std::endl;
			std::cin>>airfield>>coalition;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			addAirfield(airfield, coalition);
		}

		else if(caps(arg) == "AF-DEL")
		{
			std::string airfield;
			std::cout<<"\nplease enter the airfield..."<<std::endl;
			std::cin>>airfield;
			
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			delAirfield(airfield);
		}

		else if(caps(arg) == "AF-CHANGE")
		{
			std::string airfield, coalition;
			std::cout<<"\nplease enter the airfield and the coalition seperated with [enter]..."<<std::endl;
			std::cin>>airfield>>coalition;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			changeAirfieldCoalition(airfield, coalition);
		}

		else if(caps(arg) == "FARP-ADD")
		{
			std::string farp, coalition;
			std::cout<<"\nplease enter the farp and the coalition seperated with [enter]..."<<std::endl;
			std::cin>>farp>>coalition;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			addFarp(farp, coalition);
		}

		else if(caps(arg) == "FARP-DEL")
		{
			std::string farp;
			std::cout<<"\nplease enter the farp..."<<std::endl;
			std::cin>>farp;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
			delFarp(farp);
		}

		else if(caps(arg) == "FARP-CHANGE")
		{
			std::string farp, coalition;
			std::cout<<"\nplease enter the farp and the coalition seperated with [enter]..."<<std::endl;
			std::cin>>farp>>coalition;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			changeFarpCoalition(farp, coalition);
		}

		else
		{
			std::cout<<"\nERROR: invalid command!"<<std::endl;
		}
	}
	TERM = true;
	return;
}

void newPrompt(void)
{
	std::cout<<"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"<<std::endl;
	bool done = false;
	while(!done)
	{
		std::cout<<"\n\nWelcome to the configurator, what would you like to do?\n[AF-add, AF-del, AF-change / FARP-add, FARP-del, FARP-change / print-cur, print-dcs, term]"<<std::endl;
		std::cout<<"\n> ";	//feverdream esque programming, aaaaa!
		std::string arg;
		std::cin>>arg;
		if(!std::cin)
		{
			std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
			return;
		}
		//DEBUG
		std::cin.clear();
		std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

		if(caps(arg) == "TERM")
		{
			TERM = true;
			return;
		}
		else if(caps(arg) == "PRINT-CUR")
		{
			printAirfield(" ", true);
		}
		else if(caps(arg) == "PRINT-DCS")
		{
			std::string map;
			std::cout<<"\nplease enter for which map you'd like to print all airbases\n\n> ";
			std::cin>>map;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			printDCS_airfields(map);
		}

		else if(caps(arg) == "AF-ADD")
		{
			std::string airfield, coalition;
			std::cout<<"\nplease enter the airfield and the coalition seperated with [enter]..."<<std::endl;
			std::cin>>airfield>>coalition;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			addAirfield(airfield, coalition);
		}

		else if(caps(arg) == "AF-DEL")
		{
			std::string airfield;
			std::cout<<"\nplease enter the airfield..."<<std::endl;
			std::cin>>airfield;
			
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			delAirfield(airfield);
		}

		else if(caps(arg) == "AF-CHANGE")
		{
			std::string airfield, coalition;
			std::cout<<"\nplease enter the airfield and the coalition seperated with [enter]..."<<std::endl;
			std::cin>>airfield>>coalition;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			changeAirfieldCoalition(airfield, coalition);
		}

		else if(caps(arg) == "FARP-ADD")
		{
			std::string farp, coalition;
			std::cout<<"\nplease enter the farp and the coalition seperated with [enter]..."<<std::endl;
			std::cin>>farp>>coalition;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			addFarp(farp, coalition);
		}

		else if(caps(arg) == "FARP-DEL")
		{
			std::string farp;
			std::cout<<"\nplease enter the farp..."<<std::endl;
			std::cin>>farp;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
			delFarp(farp);
		}

		else if(caps(arg) == "FARP-CHANGE")
		{
			std::string farp, coalition;
			std::cout<<"\nplease enter the farp and the coalition seperated with [enter]..."<<std::endl;
			std::cin>>farp>>coalition;
			if(!std::cin)
			{
				std::cout<<"ERROR: oops! looks like something went wrong...\n\n"<<std::endl;
				std::cin.clear();
				std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
			
				return;
			}
			//DEBUG
			std::cin.clear();
			std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

			changeFarpCoalition(farp, coalition);
		}

		else
		{
			std::cout<<"\nERROR: invalid command!"<<std::endl;	//THE BANE OF MY EXISTANCE (std::cin>>arg1>>arg2 overflows >:[ )
		}
	}

	TERM = true;
	return;
}

void printPrompt(void)
{
	std::ifstream config(PATH);
	config >> REF;
	config.close();

	std::cout<<"\n\n\n===============\n\n"<<std::setw(4)<<REF<<"\n\n===============\n\n\n"<<std::endl;

	//printAirfield(" ", true);
	TERM = true;
	return;
}