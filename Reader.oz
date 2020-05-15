functor
import
    Open
export
   textfile:TextFile
   scan:Scan
   nextLine:NextLine

define

    % Return the next line of the opened file Infile
    % Close the file when reading is done
    fun {NextLine Infile}
       Line = {Infile getS($)}
    in
       if Line == false then
	  {Infile close}
	  none
       else
	  Line
       end
    end

    class TextFile % This class enables line-by-line reading
        from Open.file Open.text
    end

end