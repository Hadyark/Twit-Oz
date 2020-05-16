functor
import
    Open
    Parser
    System
export
    startSaver:StartSaver
    port:Port
define
    Dico
    Port
    Debug = false

    fun{UpdateDico3 TKeys TValue TValue2} NewCount NewTValue Count in
        case TKeys
        of nil then TValue
        [] Key | T then
            if Debug then{System.show updateDico3(key:Key b: {Dictionary.member TValue.dico Key})}end 
            
            if {Dictionary.member TValue.dico Key} then
            %{System.show updateDico3(iff)}
                NewCount = {Dictionary.get TValue.dico Key} + {Dictionary.get TValue2.dico Key}
            else %Si le mot lvl2 n'est pas présent
            %{System.show updateDico3(els)}
                NewCount = {Dictionary.get TValue2.dico Key}
            end 
            if {Dictionary.member TValue.dico TValue.most} then
                Count = {Dictionary.get TValue.dico TValue.most}
            else
                Count = 0
            end
            %{System.show updateDico3(x)}
            {Dictionary.put TValue.dico Key NewCount}
            %{System.show updateDico3(x2)}
            if NewCount > Count then
                NewTValue = tValue(most:Key dico:TValue.dico cnt:TValue.cnt)
                {UpdateDico3 T NewTValue TValue2}
            else
                {UpdateDico3 T TValue TValue2}
            end 
        end
    end
    fun{UpdateDico2 D HKeys HValue HValue2} TValue TValue2 NewHValue TKeys NewCount NewTValue MostValue in%Comparer les clés de Dico.HValue et D.HValue2 
        case HKeys
        of nil then HValue
        [] Key | T then
            if Debug then{System.show updateDico2(key:Key b: {Dictionary.member HValue.dico Key})}end 
            if {Dictionary.member HValue.dico Key} then
                
                TValue2 = {Dictionary.get HValue2.dico Key}
                {Dictionary.keys TValue2.dico TKeys}
                
                {Dictionary.put HValue.dico Key {UpdateDico3 TKeys {Dictionary.get HValue.dico Key} {Dictionary.get HValue2.dico Key}}}
                
                TValue = {Dictionary.get HValue.dico Key}
                
                NewCount = TValue.cnt + TValue2.cnt
                NewTValue = tValue(most:TValue.most dico:TValue.dico cnt:NewCount)
                {Dictionary.put HValue.dico Key NewTValue}
            else %Si le mot lvl2 n'est pas présent
                {Dictionary.put HValue.dico Key {Dictionary.get HValue2.dico Key}}
                TValue = {Dictionary.get HValue.dico Key}
                NewCount = TValue.cnt
            end 

            if {Dictionary.member HValue.dico HValue.most} then
                MostValue = {Dictionary.get HValue.dico HValue.most}
            else
                MostValue = tValue(cnt: 0)
            end
            
            if NewCount > MostValue.cnt then
               NewHValue = hValue(most:Key dico:HValue.dico)
                {UpdateDico2 D T NewHValue HValue2}
            else
                {UpdateDico2 D T HValue HValue2}
            end 
        end
    end
    proc{UpdateDico D Keys} HValue HValue2 HKeys in %Comparer les clés de Dico et D
        case Keys
        of nil then skip
        [] Key | T then
            if Debug then{System.show updateDico(key:Key b: {Dictionary.member Dico Key})}end 
            
            if {Dictionary.member Dico Key} then %Si la clé est présente dans Dico
                HValue = {Dictionary.get Dico Key}%Récuperer la valeur du Dico (HValue)
                HValue2 = {Dictionary.get D Key}%Récuperer la valeur du D (HValue2)
                {Dictionary.keys HValue2.dico HKeys}%Récuperer toutes les clés de HValue2.dico
                {Dictionary.put Dico Key {UpdateDico2 D HKeys HValue HValue2}}
            else %Si la clé n'est pas présente dans Dico, ajouter la valeur de D dans Dico
                {Dictionary.put Dico Key {Dictionary.get D Key}}
            end
            {UpdateDico D T}
        end

    end
    proc{PredictNext Search Predict} HValue TValue Word1 Word2 in
        if {List.length Search} == 1 then
            Word1 = Search.1
            if {Dictionary.member Dico Word1} then
                HValue = {Dictionary.get Dico Word1}
                Predict = HValue.most
            else
                Predict= 'Word not found'
            end
        else
            Word1 = Search.1
            Word2 = Search.2.1
            if {Dictionary.member Dico Word1} then
                HValue = {Dictionary.get Dico Word1}
                if {Dictionary.member HValue.dico Word2} then
                    HValue = {Dictionary.get Dico Word1}
                    TValue = {Dictionary.get HValue.dico Word2}
                    Predict = TValue.most
                else
                    {PredictNext [Word1] Predict}
                end
            elseif {Dictionary.member Dico Word2} then
                {PredictNext [Word2] Predict}
            else
                Predict= 'Word not found'
            end
        end
    end

    proc{PrintDico3 TDico TKeys}
        case TKeys 
        of nil then skip
        [] Key|T then 
            {System.show ooooooooooood3(key:Key value:{Dictionary.get TDico Key})}
            {PrintDico3 TDico T}
        end
    end
    proc{PrintDico2 HDico HKeys} Keys TValue in
        case HKeys 
        of nil then skip
        [] Key|T then 
            TValue = {Dictionary.get HDico Key}
            {System.show ooooood2(key:Key value:TValue)}
            {PrintDico3 TValue.dico {Dictionary.keys TValue.dico}}
            {PrintDico2 HDico T}
        end
    end
    proc{PrintDico Dico Keys} HValue in
        case Keys 
        of nil then skip
        [] Key|T then 
            HValue = {Dictionary.get Dico Key}
            {System.show d1(key:Key value:HValue)}
            %{System.show Key}
            {PrintDico2 HValue.dico {Dictionary.keys HValue.dico}}
            {PrintDico Dico T}
        end
    end

    proc{TreatStream Stream PortMain N Ready} Keys in
        if N >= 208 then Ready = true end
        case Stream
        of nil then skip
        []dico(D)|S then
            %{System.show saver(dicoReceived N+1)}
            {Dictionary.keys D Keys}
            {UpdateDico D Keys}
            %{PrintDico Dico {Dictionary.keys Dico}}
            %{Send PortMain kill}
            {TreatStream S PortMain N+1 Ready}
        []predict(Search Predict)|S then
            {PredictNext Search Predict}
            %{PrintDico Dico {Dictionary.keys Dico}}
            {TreatStream S PortMain N Ready}
        else
            {System.show Stream.1 PortMain N}
            {TreatStream Stream.2 PortMain N Ready}
        end
    end

    proc{StartSaver PortMain Ready}
        Stream
    in
        %{System.show saver(ready)}
        {NewPort Stream Port}
        thread
            Dico = {Dictionary.new}
            {TreatStream Stream PortMain 0 Ready}
        end
    end
end
