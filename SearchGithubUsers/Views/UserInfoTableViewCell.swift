//
//  UserInfoTableViewCell.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/11/29.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class UserInfoTableViewCell: UITableViewCell {
    
    let profileImageView = UIImageView()
    
    let nameLabel = UILabel()
    
    let repositoriesCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func commonInit() {
        setupViews()
    }
    
    func setupViews() {
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [self.nameLabel, self.repositoriesCountLabel])
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.spacing = 5
            return stackView
        }()
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(stackView)
        
        profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(10)
            $0.size.equalTo(50)
        }
        
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(profileImageView.snp.trailing).offset(5)
        }
    }
    
    func configure(withViewModel vm: UserInfoViewModel){
        nameLabel.text = vm.id
        repositoriesCountLabel.text = vm.repositoryDescription
        profileImageView.kf.setImage(with: vm.profileURL)
    }
}
