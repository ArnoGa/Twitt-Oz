functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   System
   Application
   OS
   Browser

   Reader
define
%%% Easier macros for imported functions
   Browse = Browser.browse
   Show = System.show
   Parsed
   Data

%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
   Text1 Text2 Description=td(
			      title: "Frequency count"
			      lr(
				 text(handle:Text1 width:28 height:5 background:white foreground:black wrap:word)
				 button(text:"Change" action:Press)
				 )
			      text(handle:Text2 width:28 height:5 background:black foreground:white glue:w wrap:word)
			      action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
			      )
   proc {Press} Inserted Word in
      Inserted = {Text1 getText(p(1 0) 'end' $)}
      Word = {FindNextWord {GetLastWord {Format Inserted}}}
      {Text1 tk(insert 'end' " ")}
      {Text1 tk(insert 'end' Word)}
      {Text2 set(1: Word)}
   end
   % Build the layout from the description
   W={QTk.build Description}
   {W show}

   {Text1 tk(insert 'end' "Please wait for parsing...")}
   {Text1 bind(event:"<Control-s>" action:Press)}
   thread Parsed = {ParseAllFiles 1} end
   Data = {SaveData Parsed}
   {Text1 set(1: "Parsing done")}

   %%%%%%%%%%%% Parsing functions %%%%%%%%%%%
   fun {Format S}
      case S
      of nil then nil
      [] H|T then
	      if {And {And {Or {Char.isAlNum H} == true {Char.isSpace H} == true} H \= 226} H \= 10} % exclude all non alphanumeric char, needed to exclude " and \n manually 
	         then  {Char.toLower H} | {Format T}
	      else {Format T} end
	   end
   end

   fun {RemoveDoubleSpaces S} 
      case S
      of nil then nil
      [] H|T then
         if T \= nil then
            if {And {Char.isSpace H} == true {Char.isSpace T.1}} then {RemoveDoubleSpaces T}
            else H | {RemoveDoubleSpaces T} end
         else
            H|{RemoveDoubleSpaces T}
         end
      end
   end

   fun {FormatAndSplit Str}
	   {String.tokens {RemoveDoubleSpaces {Format Str}} & }
   end

   fun {ParseFile IN_NAME}
	   File = {New Reader.textfile init(name:IN_NAME)}
	   fun {ParseLines File}
	      Line = {Reader.nextLine File}
	   in
	      if Line == none then nil
	      else
	         thread {FormatAndSplit Line} end | {ParseLines File}
	      end
	   end
      in
	      {ParseLines File}
   end

   fun {ParseAllFiles N}
	   IN_NAME ="tweets/part_"#N#".txt"
   in
	   if N == 209 then nil
	   else
	      {Append thread {ParseFile IN_NAME} end {ParseAllFiles N+1}}
	   end
   end

   %Data.values are list of words
   fun {SaveData Parsed}
      Data = {Dictionary.new}
      proc {ReadParsedLines D L}
         proc {ReadParsedGroup D L}
            case L
            of nil then skip
            [] H|T then
               if T \= nil then
                  if {Dictionary.member D {String.toAtom H}} == true then
                     {Dictionary.put D {String.toAtom H} {Append {Dictionary.get D {String.toAtom H}} T.1|nil}} % append value with T.1 for the key H
                  else 
                     {Dictionary.put D {String.toAtom H} T.1|nil} 
                  end
                  {ReadParsedGroup D T}
               else skip end
            end
         end
         in
         case L
         of nil then skip
         [] H|T then
            {ReadParsedGroup Data H}
            {ReadParsedLines Data T}
         end
      end
      in
      {ReadParsedLines Data Parsed}
      Data
   end
   

   %%%%%%%%%%%% Predictive functions %%%%%%%%%%%
   fun {GetLastWord S}
      Splitted
      in
      Splitted = {String.tokens S & }
      case Splitted of nil then ""
      else
         {List.last Splitted}
      end
   end

   fun {FindNextWord W}
      Pairs = {Dictionary.condGet Data {String.toAtom W} nil}
      in
      case Pairs of nil then "I"
      else
         {MostOccurIn Pairs}
      end      
   end

   /*
    *  P       ->  A list of all the values of a dictionary key
    *  Current ->  Current word the function is checking
    *  Word    ->  Word with the most occur for now
    *  Max     ->  Number of occur of Word
    */
   fun {MostOccurIn P}
      fun {MostOccur P Current Word Max}
         N
         in
         case Current
         of nil then Word
         [] H|T then
            N = {Count P H}
            if N > Max then
               {MostOccur P T H N}
            else
               {MostOccur P T Word Max}
            end
         end
      end
      in
      {MostOccur P P.1 P.1 0}
   end

   fun {Count L Word}
      fun {CountRecur C L Word}
         case L
         of nil then C
         [] H|T then
            if Word == H then {CountRecur C+1 T Word}
            else {CountRecur C T Word}
            end
         end
      end
      in
      {CountRecur 0 L Word}
   end

end
