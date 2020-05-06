functor
import
    Open
    Saver
    System
export
    startParser:StartParser
define
    Dico
    Debug = false
    proc{ParseLine Line} HValue TValue PValue MostUsed MostUsedT in
    
        case Line
        of nil then skip
        [] H | T then
        if Debug then{System.show H}end
            if {Dictionary.member Dico H} then %Si le mot lvl1 est présent
                if Debug then {System.show if1}end
                HValue = {Dictionary.get Dico H} %Get la valeur pour lvl1
                if T \= nil andthen {Dictionary.member HValue.dico T.1} then %Si le mot lvl2 est présent dans le dico de lvl1
                if Debug then{System.show if2}end
                    TValue = {Dictionary.get HValue.dico T.1}  %Get la valeur pour lvl2
                    {Dictionary.put HValue.dico T.1 tValue(most:TValue.most dico:TValue.dico cnt:TValue.cnt+1)}  %Modifier le count lvl2
                    if HValue.most \= null then
                        MostUsed = {Dictionary.get HValue.dico HValue.most}  %récuperer le mot le plus utilisé apres lvl1
                        %Checker le mot le plus utilisé change
                        if TValue.cnt+1 > MostUsed.cnt then  %Si oui changer le most et dico
                            if Debug then{System.show if3}end
                            {Dictionary.put Dico H hValue(most:T.1 dico:HValue.dico)}
                        end
                    else
                        {Dictionary.put Dico H hValue(most:T.1 dico:HValue.dico)}
                    end
                    
                    if T.2 \= nil andthen {Dictionary.member TValue.dico T.2.1} then
                        if Debug then{System.show if4}end
                        PValue = {Dictionary.get TValue.dico T.2.1}  %Get la valeur pour lvl3
                        {Dictionary.put TValue.dico T.2.1 PValue+1}  %Modifier le count lvl2
                        if TValue.most \= null then
                            MostUsedT = {Dictionary.get TValue.dico TValue.most}  %récuperer le mot le plus utilisé apres lvl1
                        else
                            MostUsedT =0
                        end
                        %Checker le mot le plus utilisé change
                        if PValue+1 > MostUsedT then  %Si oui changer le most et dico
                            if Debug then{System.show if5}end
                            {Dictionary.put HValue.dico T.1 tValue(most:T.2.1 dico:TValue.dico cnt:TValue.cnt)}
                        end 
                    elseif T.2 \= nil then %Si le mot lvl3 n'est pas présent dans le dico de lvl2
                        if Debug then{System.show if4elseif}end
                        {Dictionary.put TValue.dico T.2.1 1}
                    end
                elseif T \= nil then %Si le mot lvl2 n'est pas présent dans le dico de lvl1
                    if Debug then{System.show if2elseif}end
                    {Dictionary.put HValue.dico T.1 tValue(most:null dico:{Dictionary.new} cnt:1)}
                end
            else %Si le mot lvl1 n'est pas présent
                if Debug then{System.show else1}end
                if T \= nil then
                    if Debug then{System.show else1if1}end
                    {Dictionary.put Dico H hValue(most:T.1 dico:{Dictionary.new})}%Ajouter au Dico
                    HValue = {Dictionary.get Dico H}
                    {Dictionary.put HValue.dico T.1 tValue(most:null dico:{Dictionary.new} cnt:1)}%Ajouter Lvl2 au Dico de Lvl1
                    if T.2 \= nil then
                        if Debug then{System.show else1if1if}end
                        TValue = {Dictionary.get HValue.dico T.1}
                        {Dictionary.put TValue.dico T.2.1 1}
                        {Dictionary.put HValue.dico T.1 tValue(most:T.2.1 dico:TValue.dico cnt:1)}%Ajouter Lvl2 au Dico de Lvl1
                    end
                else
                    if Debug then{System.show elseelse}end
                    {Dictionary.put Dico H hValue(most:null dico:{Dictionary.new})}%Ajouter au Dico
                end
            end
            {ParseLine T}
        end
    end
    
    proc{TreatStream Stream}
        UpdatedDico
        in
        case Stream
        of nil then skip
        []parse(Line)|S then
            {ParseLine Line}
            {TreatStream S}
        []endFile|S then  
            {System.show parser(endFile)}  
            {Send Saver.port dico(Dico)}
        end
    end

    fun{StartParser}
        Stream
        Port
    in
        {NewPort Stream Port}
        Dico = {Dictionary.new}
        thread
            {TreatStream Stream}
        end
        Port
    end
end