//
//  DescribingSources.swift
//  Gi-ukForMoments
//
//  Created by goya on 01/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

struct DescribingSources {
    static private let language = Locale.current.languageCode
    
    struct sectionsFontSize {
        static let maxFontSize : Int = 16
        static let minFontSize : Int = 14
    }
    
    struct MainTagView {
        
        static func centeredImageSource() -> NSMutableAttributedString {
            let iconsSize = CGRect(x: 0, y: 0, width: 30, height: 30)
            let attachment = NSTextAttachment()
            let imageTemplate = UIImage(named: ButtonImageNames.ButtonName_Main_Giuk)?.withRenderingMode_alwaysTemplate
            attachment.image = imageTemplate
            attachment.bounds = iconsSize
            let stringImage = NSAttributedString(attachment: attachment)
            let blankString = NSAttributedString(string: " ")
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byTruncatingTail
            
            let frame = NSMutableAttributedString(string: " ", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            frame.append(NSMutableAttributedString(attributedString: stringImage))
            frame.append(NSMutableAttributedString(attributedString: blankString))
            
            return frame
        }
        
        static var notice_Title: String {
            switch DescribingSources.language {
            case "kor": return "\n기억을 만드세요"
            default : return ""//"\ncreate new 'Gi-uk' album"
            }
        }
        static var notice_SubTiltle: String {
            switch DescribingSources.language {
            case "kor": return "\n상단에있는 버튼을 눌러\n새로운 기억을 만드세요"
            default : return "\ncreate new album by pressing\nthe button on the top"
            }
        }
        
        static var deleteTag_notice_Title: String {
            switch DescribingSources.language {
            case "kor": return "삭제"
            default : return "DELETE"
            }
        }
        static var deleteTag_notice_SubTiltle: String {
            switch DescribingSources.language {
            case "kor": return "연관된 기억이 다른 앨범에 연결되있지 않다면,\n기억도 함께 지워집니다."
            default : return "related Gi-uk could be deleted\nif it has no links to other album"
            }
        }
        static var delete_Title_DeleteAction: String {
            switch DescribingSources.language {
            case "kor": return "삭제"
            default : return "delete album"
            }
        }
        static var delete_Title_CancelAction: String {
            switch DescribingSources.language {
            case "kor": return "취소"
            default : return "cancel"
            }
        }
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
    
    struct deleteSection {
        static var delete_Title: String {
            switch DescribingSources.language {
            case "kor": return "삭제"
            default : return "Delete"
            }
        }
        
        static var delete_SubTitle: String {
            switch DescribingSources.language {
            case "kor": return "앨범에서 빼거나 삭제합니다"
            default : return "remove Gi-uk from album or delete"
            }
        }
        
        static var delete_Title_DeleteAction: String {
            switch DescribingSources.language {
            case "kor": return "삭제(모든앨범에서 제거)"
            default : return "delete from storage"
            }
        }
        static var delete_Title_RemoveAction: String {
            switch DescribingSources.language {
            case "kor": return "이 앨범에서 빼기"
            default : return "remove from this album"
            }
        }
        static var delete_Title_CancelAction: String {
            switch DescribingSources.language {
            case "kor": return "취소"
            default : return "cancel"
            }
        }
    }
}
