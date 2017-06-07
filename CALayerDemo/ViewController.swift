//
//  ViewController.swift
//  CALayerDemo
//
//  Created by zzzsw on 2017/6/7.
//  Copyright © 2017年 zzzsw. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    var timer : DispatchSourceTimer!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .red;

        //dashLineShapeLayerWithBezierPath()
        //bezierPathAddArcDescCircle()
        //bezierPathRect();



        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(ViewController.vcAction(ges:))))
        self.view.isUserInteractionEnabled = true

    }

    func vcAction(ges:UITapGestureRecognizer){



        self.view.transformCircleColor(ToColor: UIColor.init(red: CGFloat(Double(arc4random_uniform(255))/255.0), green: CGFloat(Double(arc4random_uniform(255))/255.0), blue: CGFloat(Double(arc4random_uniform(255))/255.0), alpha: 1), Duration: 2, StartPoint: CGPoint.init(x: 0, y: 0))

        //self.view.transformCircleImage(ToImage: UIImage(), Duration: 3, StartPoint: CGPoint.init(x: 300, y: 400));

        //self.view.transformBeginZoom(max: 2, min: 0.8)

    }


    func dashLineShapeLayerWithBezierPath(){
        let dashLineShapeLayer = CAShapeLayer.init()
        //创建贝塞尔曲线
        let dashLinePath = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: 200, height: 100), cornerRadius: 20)
        dashLineShapeLayer.path = dashLinePath.cgPath
        dashLineShapeLayer.position = CGPoint.init(x: 100, y: 100)
        dashLineShapeLayer.fillColor = UIColor.clear.cgColor
        dashLineShapeLayer.strokeColor = UIColor.white.cgColor
        dashLineShapeLayer.lineWidth = 3
        dashLineShapeLayer.lineDashPattern = [6,6]
        dashLineShapeLayer.strokeStart = 0
        dashLineShapeLayer.strokeEnd = 1
        dashLineShapeLayer.zPosition =  999
        self.view.layer.addSublayer(dashLineShapeLayer)
        /*开启线程添加定时器 执行动画*/
        let afterTime  = DispatchTime.now() + 0.3
        let timeInterval = 0.1
        //创建子线程队列
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        //使用之前创建的队列来创建计时器
        let timer = DispatchSource.makeTimerSource(queue: queue);
        timer.scheduleRepeating(deadline: DispatchTime.now(), interval: timeInterval,leeway: .nanoseconds(0));
        timer.setEventHandler {
            DispatchQueue.main.asyncAfter(deadline: afterTime, execute: {
                let _add : CGFloat = 3;
                dashLineShapeLayer.lineDashPhase -= _add;
            })
        }
        timer.setCancelHandler {
            print("倒计时结束");
        }
        timer.resume();self.timer = timer;
    }


    func bezierPathAddArcDescCircle(){
        let path = UIBezierPath.init()
        let circleCenter = view.center
        path.move(to: CGPoint.init(x: circleCenter.x + 50, y: circleCenter.y))
        path.addArc(withCenter: circleCenter, radius: 50, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
        path.move(to: CGPoint.init(x: circleCenter.x+100, y: circleCenter.y))
        path.addArc(withCenter: circleCenter, radius: 100, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
        path.move(to: CGPoint.init(x: circleCenter.x+150, y: circleCenter.y))
        path.addArc(withCenter: circleCenter, radius: 150, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
        //Create shape layer
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = UIColor.green.cgColor
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.lineWidth = 5
        shapeLayer.lineJoin = kCALineJoinBevel
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.path = path.cgPath
        self.view.layer.addSublayer(shapeLayer)
    }


    func bezierPathRect(){
        let bezierPath_rect = UIBezierPath.init(rect: CGRect.init(x: 30, y: 50, width: 100, height: 100))
        bezierPath_rect.lineWidth = 10
        let shapeLayer : CAShapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath_rect.cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0.3
        self.view.layer.addSublayer(shapeLayer)
    }

    func deinitTimer(){
        if let time = self.timer {
            time.cancel();
            timer = nil;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}





/*点击扩散的库 主要用到蒙版mask以及shapeLayer和核心动画*/
extension UIView:CAAnimationDelegate{

    func transformCircleColor(ToColor color:UIColor,Duration duration:CGFloat,StartPoint startPoint:CGPoint){

        var tempLayer : CALayer? = objc_getAssociatedObject(self, "tempLayer") as? CALayer
        if tempLayer == nil {
            tempLayer = CALayer()
            tempLayer!.bounds = self.bounds
            tempLayer!.position = self.center
            tempLayer!.backgroundColor = self.backgroundColor?.cgColor
            self.layer.addSublayer(tempLayer!)
            objc_setAssociatedObject(self, "tempLayer", tempLayer!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }


        tempLayer!.contents = nil
        tempLayer!.backgroundColor = color.cgColor
        let screenHeight = self.frame.size.height
        let screenWidth = self.frame.size.width
        let rect = CGRect.init(x: startPoint.x, y: startPoint.y, width: 2, height: 2)
        let startPath = UIBezierPath.init(ovalIn: rect)
        let endPath = UIBezierPath.init(arcCenter: startPoint, radius: sqrt(screenHeight*screenHeight + screenWidth * screenWidth), startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)

        let maskLayer = CAShapeLayer.init()
        maskLayer.path = endPath.cgPath
        tempLayer!.mask = maskLayer


        let animation = CABasicAnimation.init(keyPath: "path");
        animation.delegate = self as CAAnimationDelegate;
        animation.fromValue = startPath.cgPath;
        animation.toValue = endPath.cgPath;
        animation.duration = CFTimeInterval(duration);
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut);
        animation.setValue("CircleColor_Value", forKey: "CircleColor_Key");

        maskLayer.add(animation, forKey: "CircleColor");

    }




    func transformCircleImage(ToImage image:UIImage,Duration duration:CGFloat,StartPoint startPoint:CGPoint){

        var tempLayer : CALayer? = objc_getAssociatedObject(self, "tempLayer") as? CALayer

        if tempLayer == nil {
            tempLayer = CALayer();
            tempLayer!.bounds = self.bounds;
            tempLayer!.position = self.center;
            tempLayer!.backgroundColor = self.backgroundColor?.cgColor
            self.layer.addSublayer(tempLayer!)
            objc_setAssociatedObject(self, "tempLayer", tempLayer!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        tempLayer!.contents = image.cgImage

        let screenHeight = self.frame.size.height
        let screenWidthb = self.frame.size.width
        let rect = CGRect.init(x: startPoint.x, y: startPoint.y, width: 2, height: 2)
        let startPath = UIBezierPath.init(ovalIn: rect)
        let endPath = UIBezierPath.init(arcCenter: startPoint, radius: sqrt(screenHeight*screenHeight + screenWidthb*screenWidthb), startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)

        let maskLayer = CAShapeLayer.init()
        maskLayer.path = endPath.cgPath
        tempLayer!.mask = maskLayer


        let animation = CABasicAnimation.init(keyPath: "path")
        animation.delegate = self as CAAnimationDelegate;
        animation.fromValue = startPath.cgPath
        animation.toValue = endPath.cgPath
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.setValue("CircleImage_Value", forKey: "CircleImage_Key")
        maskLayer.add(animation, forKey: "CircleImage")

    }





    func transformBeginZoom(max:CGFloat,min:CGFloat){
        UIView.animate(withDuration: 0.3, animations: { 

            self.transform = CGAffineTransform.init(scaleX: max, y: max)


        }) { (finish) in
            UIView.animate(withDuration: 0.3, animations: { 

                self.transform = CGAffineTransform.init(scaleX: min, y: min)

            }, completion: { (finish) in

                let nextStop : NSNumber? = objc_getAssociatedObject(self, "nextAniStop") as? NSNumber

                if nextStop != nil && nextStop!.boolValue == true {

                    UIView.animate(withDuration: 0.3, animations: { 

                        self.transform = CGAffineTransform.init(scaleX: 1, y: 1)

                    }, completion: { (finish) in

                        self.transform = CGAffineTransform.init(scaleX: 1, y: 1);
                        objc_setAssociatedObject(self, "nextAniStop", NSNumber.init(value: 0), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    })

                }else{
                    self.transformBeginZoom(max: max, min: min)
                }

            })
        }

    }




    func transformStopZoom(){
        objc_setAssociatedObject(self, "nextAniStop", NSNumber.init(value: true), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }


    func animationDidStop(anim:CAAnimation,finishFlag:Bool){
        if finishFlag {
            let tempLayer : CALayer = objc_getAssociatedObject(self, "CircleColor_Key") as! CALayer
            if (anim.value(forKey: "CircleColor_Key") != nil) {
                self.layer.contents = nil;
                self.backgroundColor = UIColor.init(cgColor: tempLayer.backgroundColor!);
            }else if((anim.value(forKey: "CircleImage_Key")) != nil){
                self.layer.contents = tempLayer.contents;
            }
        }
    }






}











