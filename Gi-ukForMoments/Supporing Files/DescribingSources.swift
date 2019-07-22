//
//  DescribingSources.swift
//  Gi-ukForMoments
//
//  Created by goya on 01/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import Foundation

struct DescribingSources {
    static private let language = Locale.current.languageCode
    
    struct sectionsFontSize {
        static let maxFontSize : Int = 16
        static let minFontSize : Int = 14
    }
    
    struct imageCropSection {
        static var notice_Title: String {
            switch DescribingSources.language {
            case "kor": return "사진을 선택하세요"
            default : return "choose a moment"
            }
        }
        static var notice_SubTiltle: String {
            switch DescribingSources.language {
            case "kor": return "\n사진을 확대하거나 축소하며\n위치를 조정하세요"
            default : return "\nzooming and scrolling\nto crop the photo"//"\nreposition the photo\nwith zooming in or out"
            }
        }
        static var placeHolder_Tilte: String {
            switch DescribingSources.language {
            case "kor": return "사진을 편집"
            default : return "Edit photo"
            }
        }
        static var placeHolder_SubTilte: String {
            switch DescribingSources.language {
            case "kor": return "\n줌 혹은 스크롤하여\n보여질 위치를 조정하새요"
            default : return "\nzoom and scroll the photo\nto change crop"
            }
        }
    }
    
    struct textInPutSection {
        static var notice_Title: String {
            switch DescribingSources.language {
            case "kor": return "✎\n메모를 작성하세요"
            default : return "✎\nwrite a comment"
            }
        }
        static var notice_SubTiltle: String {
            switch DescribingSources.language {
            case "kor": return "\n500자 이하로 작성\n할 수 있습니다"
            default : return "\ncan be written under 500 letters"
            }
        }
    }
    
    struct choosingTagSection {
        static var choosingTagTilte: String {
            switch DescribingSources.language {
            case "kor": return "앨범"
            default : return "ALBUM"
            }
        }
        static var notice_Title: String {
            switch DescribingSources.language {
            case "kor": return "앨범을 추가하세요"
            default : return "add album"
            }
        }
        static var notice_SubTiltle: String {
            switch DescribingSources.language {
            case "kor": return "\n최소한 하나이상의 앨범을 선택해야 합니다"
            default : return "\nneeds one or more album, to save"
            }
        }
    }
}
