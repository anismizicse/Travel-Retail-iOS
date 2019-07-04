//
//  CircularVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/13/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import RealmSwift

class CircularVC: UIViewController {
    
    var realm = try! Realm()
    
    lazy var fetchCirculars: Results<CircularInfo> = {self.realm.objects(CircularInfo.self)}()
    lazy var fetchGuidelines: Results<GuidelineInfo> = {self.realm.objects(GuidelineInfo.self)}()
    var allSlides: [Slide] = []
    
    @IBOutlet weak var circularScroll: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if Utils.circular {
            title = "Circular"
        }else{
            title = "Guideline"
        }
        
        setSlidePages()
        pageControl.numberOfPages = allSlides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        
    }
    
    func setSlidePages(){
        
        if Utils.circular{
            
            if fetchCirculars.count != 0{
                
                for circular in fetchCirculars{
                    
                    let slide: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                    
                    createBorders(slide: slide)
                    
                    slide.refValue.text = circular.ref
                    slide.dateValue.text = Utils.formatDate(date: circular.date)
                    slide.fromValue.text = circular.created_from
                    slide.toText.text = circular.created_to
                    slide.subValue.text = circular.subject
                    slide.message.text = circular.message
                    
                    allSlides.append(slide)
                    
                }
                
                setSlides()
            }
            
        }else if Utils.guideline{
            
            if fetchGuidelines.count != 0{
                
                for guideline in fetchGuidelines{
                    
                    let slide: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                    
                    createBorders(slide: slide)
                    
                    slide.refValue.text = guideline.ref
                    slide.dateValue.text = Utils.formatDate(date: guideline.date)
                    slide.fromValue.text = guideline.created_from
                    slide.toText.text = guideline.created_to
                    slide.subValue.text = guideline.subject
                    slide.message.text = guideline.message
                    
                    allSlides.append(slide)
                    
                }
                
                setSlides()
            }
        }
        
        
    }
    
    func setSlides(){
        circularScroll.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        circularScroll.contentSize = CGSize(width: view.frame.width * CGFloat(allSlides.count), height: view.frame.height)
        circularScroll.isPagingEnabled = true
        
        for i in 0..<allSlides.count{
            allSlides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            circularScroll.addSubview(allSlides[i])
        }
    }
    
    func createBorders(slide: Slide){
        
        slide.refNo.layer.borderWidth = 1.0
        slide.refNo.layer.borderColor = UIColor.black.cgColor
        
        slide.refValue.layer.borderWidth = 1.0
        slide.refValue.layer.borderColor = UIColor.black.cgColor
        
        slide.dateText.layer.borderWidth = 1.0
        slide.dateText.layer.borderColor = UIColor.black.cgColor
        
        slide.dateValue.layer.borderWidth = 1.0
        slide.dateValue.layer.borderColor = UIColor.black.cgColor
        
        slide.fromText.layer.borderWidth = 1.0
        slide.fromText.layer.borderColor = UIColor.black.cgColor
        
        slide.fromValue.layer.borderWidth = 1.0
        slide.fromValue.layer.borderColor = UIColor.black.cgColor
        
        slide.toText.layer.borderWidth = 1.0
        slide.toText.layer.borderColor = UIColor.black.cgColor
        
        slide.toValue.layer.borderWidth = 1.0
        slide.toValue.layer.borderColor = UIColor.black.cgColor
        
    }
    
    
}
