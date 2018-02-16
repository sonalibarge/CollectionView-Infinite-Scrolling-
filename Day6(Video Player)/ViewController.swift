//
//  ViewController.swift
//  Day6(Video Player)
//
//  Created by Sonali on 2/1/18.
//  Copyright © 2018 Sonali. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class ViewController: UIViewController ,UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    var isPageFirst : Bool = true
   
    var lastContentOffset : CGFloat = 0
    let playerController = AVPlayerViewController()
    var avPlayer: AVPlayer?
    private var photosUrlArray = [String]()
  //  private var textDescriptionArray = [String]()
    var stringArray : NSArray = []
    var toScrollIndex = 0;
    let WINDOW_WIDTH = UIScreen.main.bounds.width
    let WINDOW_HEIGHT = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControl.currentPage = 0
        self.automaticallyAdjustsScrollViewInsets = false
        photosUrlArray = ["Welcome you can sign in ","Browse in app","Locate distance","Offline saving data"]
        pageControl.numberOfPages = self.photosUrlArray.count
        if photosUrlArray.count > 2{
            
            // Insert text last object in to the first index of photos array
            photosUrlArray.insert(photosUrlArray.last!, at: 0)
            
            // Add origianl text array's first object (before adding last object at index 0) in the last index of photo array.
            photosUrlArray.append(photosUrlArray[1])
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let videoPath = Bundle.main.path(forResource: "Vertical Video", ofType: "mp4")else{
            print("No video found")
            return
        }
        avPlayer = AVPlayer(url: URL(fileURLWithPath: videoPath))
        var avPlayerLayer = AVPlayerLayer(player:avPlayer)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer?.volume = 0
        avPlayer?.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = UIColor.clear;
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(replayVedio), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer?.play()
        if photosUrlArray.count > 2{
            //self.pageControl.currentPage = NSIndexPath(row: 1, section: 0).row
            videoCollectionView.scrollToItem(at: NSIndexPath(row: 1, section: 0)  as IndexPath, at: .left, animated: false)
        }
    }
    @objc func replayVedio() {
        self.avPlayer?.seek(to: kCMTimeZero)
        self.avPlayer?.play()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.videoCollectionView.collectionViewLayout = layout
        self.videoCollectionView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:0, right: 0)
        
        if let layout = self.videoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            // let itemWidth = view.bounds.width / 3.0
            // let itemHeight = layout.itemSize.height
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.itemSize = CGSize(width: self.view.frame.size.width, height: self.videoCollectionView.frame.size.height-10)
            layout.invalidateLayout()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func photoForIndexPath(indexPath: NSIndexPath) -> String {
        return photosUrlArray[indexPath.row]
    }
    
    func reversePhotoArray(photoArray:[String], startIndex:Int, endIndex:Int){
        if startIndex >= endIndex{
            return
        }
        self.photosUrlArray.swapAt(startIndex, endIndex)
        reversePhotoArray(photoArray: photosUrlArray, startIndex: startIndex + 1, endIndex: endIndex - 1)
    }
}

extension ViewController : UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosUrlArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let continousCollectionViewCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ContinousCollectionViewCell", for: indexPath)as! ContinousCollectionViewCell
        continousCollectionViewCell.titleLabel.text = "Welcome"
        //2
        let photoName = photoForIndexPath(indexPath: indexPath as NSIndexPath)
        
        //3
        continousCollectionViewCell.descriptionLabel.text = photoName
        
        return continousCollectionViewCell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.lastContentOffset > scrollView.contentOffset.x {
            print("Right")
            print("Visible cell \(videoCollectionView.indexPathsForVisibleItems)")
            if let indexPath = videoCollectionView.indexPathsForVisibleItems.last {
                if indexPath.row > 0  && indexPath.row <= pageControl.numberOfPages{
                    if indexPath.row - 2 < 0{
                        pageControl.currentPage = pageControl.numberOfPages
                    }else{
                        pageControl.currentPage = indexPath.row - 2
                    }
                }else if(indexPath.row > pageControl.numberOfPages){
                       
                        pageControl.currentPage = 0
                }
            }
        }else if self.lastContentOffset < scrollView.contentOffset.x{
            print("Left")
            print("Visible cell \(videoCollectionView.indexPathsForVisibleItems)")
            if let indexPath = videoCollectionView.indexPathsForVisibleItems.last {
                if indexPath.row > 0  && indexPath.row <= pageControl.numberOfPages{
                    pageControl.currentPage = indexPath.row - 1
                }else if(indexPath.row > pageControl.numberOfPages){
                    pageControl.currentPage =  0
                }
            }
        }
        self.lastContentOffset = scrollView.contentOffset.x
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Calculate where the collection view should be at the right-hand end item
        
        
        
        let fullyScrolledContentOffset:CGFloat = videoCollectionView.frame.size.width * CGFloat(photosUrlArray.count - 1)
        
        if (scrollView.contentOffset.x >= fullyScrolledContentOffset - videoCollectionView.frame.width/2) {
            
            // user is scrolling to the right from the last item to the 'fake' item 1.
            // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
                        videoCollectionView.scrollToItem(at: NSIndexPath(row: 1, section: 0) as IndexPath, at: .left, animated: false)
            
        }
        else if (scrollView.contentOffset.x <= 0){
            videoCollectionView.scrollToItem(at:NSIndexPath(row: photosUrlArray.count - 2, section: 0)  as IndexPath, at: .left, animated: false)
        }
    }

}

