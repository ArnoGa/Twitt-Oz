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

%%% Read File
   fun {GetFirstLine IN_NAME}
      {Reader.scan {New Reader.textfile init(name:IN_NAME)} 1}
   end

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
   proc {Press} Inserted in
      Inserted = {Text1 getText(p(1 0) 'end' $)} % example using coordinates to get text
      {Text2 set(1:Inserted)} % you can get/set text this way too
   end
    % Build the layout from the description
   W={QTk.build Description}
   {W show}

   {Text1 tk(insert 'end' {GetFirstLine "tweets/part_1.txt"})}
   {Text1 bind(event:"<Control-s>" action:Press)} % You can also bind events

   
   %{Dictionary.put Data test 1|nil}
   %{Dictionary.put Data test  {Append {Dictionary.get Data test} 2} }
   %{Browse {Dictionary.get Data test}}

   fun {Format S}
      case S
      of nil then nil
      [] H|T then
	      if {And {Or {Char.isAlNum H} == true {Char.isSpace H} == true} H \= 226}
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

   fun {SaveData Parsed}
      Data = {Dictionary.new}
      proc {ReadParsedLines D L}
         proc {ReadParsedGroup D L}
            case L
            of nil then skip
            [] H|T then
               if T \= nil then
                  if {Dictionary.member D {String.toAtom H}} == true then
                     {Dictionary.put D {String.toAtom H} {Append {Dictionary.get D {String.toAtom H}} T.1|nil}}
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


   %{Browse {ParseFile "tweets/part_1.txt"}}

   thread Parsed = {ParseAllFiles 1} end
   thread Data = {SaveData Parsed} end
   {Browse {Dictionary.entries Data}}



end
