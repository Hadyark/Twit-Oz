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
    proc{PredictNext Word1 Next}
        Next='predict1'
    end
    proc{TreatStream Stream}
        case Stream
        of nil then skip
        []dico(D)|S then
            {System.show saver(dicoReceived)}
            Dico=D
            {TreatStream S}
        []predict(Word1 Next)|S then
            {PredictNext Word1 Next}
            {TreatStream S}
        []predict(Word1 Word2 Next)|S then
            Next='bpredict2'
            {TreatStream S}
        else
            {System.show Stream.1}
            {TreatStream Stream.2}
        end
    end

    proc{StartSaver}
        Stream
    in
        {System.show saver(ready)}
        {NewPort Stream Port}
        thread
            {TreatStream Stream}
        end
    end
end
