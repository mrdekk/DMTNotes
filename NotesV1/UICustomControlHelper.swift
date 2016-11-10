//
//  UICustomViewContainer.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 03.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

extension UIView {
    func loadSubviewFromXib() {
        if let view = loadViewFromNib() {
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

            addSubview(view)
        }
    }

    private func loadViewFromNib() -> UIView? {
        let type = type(of: self)
        let className = String(describing: type)
        //let s = String(describing: Bundle.allBundles)
        //fatalError(s)
        //Bundle.allBundles
        let bundle = Bundle(for: type)
        let nib = UINib(nibName: className, bundle: bundle)
        let objects = nib.instantiate(withOwner: self, options: nil)
        let view = objects.first(where: { p in p is UIView }) as? UIView
        return view
    }
}
