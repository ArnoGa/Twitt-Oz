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
   Data = {Dictionary.new}

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

   S = "j'Ai envie dE tester un stRing, parce que jsp cOmment ca marche"

   fun {Format S}
      case S
      of nil then nil
      [] H|T then
	 if {Or {Char.isAlpha H} == true {Char.isSpace H} == true}
	 then  {Char.toLower H} | {Format T}
	 else {Format T}
	 end
      end
   end

   fun {FormatAndSplit Str}
      {String.tokens {Format Str} & }
   end

   fun {ParseFile IN_NAME}
      File = {New Reader.textfile init(name:IN_NAME)}
      fun {ParseLines File}
	 Line = {Reader.nextLine File}
      in
	 if Line == none then
	    nil
	 else
	    thread {FormatAndSplit Line} end | {ParseLines File}
	 end
      end
   in
      {ParseLines File}
   end

   {Browse {ParseFile "tweets/part_1.txt"}}
   
end
