GPaperTrans
=====================

Yet another UICollectionView layout transitions inspired by Facebook Paper App in Swift

![Demo GPaperTrans](https://raw.githubusercontent.com/Goro-Otsubo/raw/master/transDemo.gif)


## How to run 

Please do not forget to run "pods install" before running the program. 
You can try "Standard" first. Then, you can try "Responsive"

I hope you will notice two differenes.

*  "Responsive" would be a little bit more responsive to gesture.
* In "Standard", you will notice some of the swipe will be ignored.

## How it works

This is basically UICollectionView layout to layout transition. (like taktamur/PAMTransitionSample[https://github.com/taktamur/PAMTransitionSample]) 

There are two main differences.

1) AsynchNode from facebook is used in "Responsive" version instead of UIImageView. This makes transition a little bit more responsive. (Very subtle difference)

2)In "Standard" version, UICollectionView.finishInteractiveTransition() is called after UIPanGestureRecoginizer returned  UIGestureRecognizerState.Ended. 

Since finishing animation takes longer than expected, when the user begins new interaction before the animation finishes, it will be ignored.

In "Responsive" version, most of the finishing animation is controlled by Pop (also by Facebook). Since animation by pop can be interrupted, swipe action will not be ignored (in most cases. I admit still some of the swipe is ignored)


## Todo
* Simuletaneous horizontal and vertical pan gesture. (Tried, but not working. Still a long way to go)
* Use ASCollectionView
* Use TLLayoutTransitioning[https://github.com/wtmoose/TLLayoutTransitioning]

## Requirements
* iOS 8 or higher
* ARC

## Contact me

**Goro Otsubo**  

* LinkedIn: [https://www.linkedin.com/pub/goro-otsubo/][1] 

  [1]: https://www.linkedin.com/pub/goro-otsubo/

  


## LicenseThis software is released under the MIT License, see LICENSE.txt.