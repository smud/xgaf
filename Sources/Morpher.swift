// XGAF file format parser for Swift.
// (c) 2016 Andrey Fidrya. MIT license. See LICENSE for more information.

import Foundation

class Morpher {
    enum State {
        case copyText
        case copyAnimateForms
        case copyInanimateForms
    }
    
    let cases: GrammaticalCases
    var state: State = .copyText
    var animate = false
    
    init(cases: GrammaticalCases) {
        self.cases = cases
    }
    
    func convertToSimpleAreaFormat(text: String) -> String {
        var result = ""
        var forms = ""
        state = .copyText
        animate = false
        
        for character in text.characters {
            switch state {
            case .copyText:
                switch character {
                    case "(":
                        state = .copyAnimateForms
                    case "[":
                        state = .copyInanimateForms
                    default:
                        result.append(character)
                }
            case .copyAnimateForms:
                switch character {
                    case ")":
                        result.append(expand(forms: forms, animate: true))
                        forms = ""
                        state = .copyText
                    default:
                        forms.append(character)
                }
            case .copyInanimateForms:
                switch character {
                    case "]":
                        result.append(expand(forms: forms, animate: false))
                        forms = ""
                        state = .copyText
                    default:
                        forms.append(character)
                }
            }
        }
        
        if !forms.isEmpty { // unterminated brackets?
            result += forms // recover
        }
        
        return result
    }
    
    private func expand(forms: String, animate: Bool) -> String {
        let casesByNominativeCase = animate ?
            self.cases.animateByNominativeCase :
            self.cases.inanimateByNominativeCase
        
        guard let cases = casesByNominativeCase[forms] else {
            return "(\(forms))" // pass string "as is"
        }
        let forms = cases.joined(separator: ",")
        return "(\(forms))"
    }
}
