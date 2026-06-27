//
//  UserCell.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import UIKit

final class UserCell: UITableViewCell {
    static let reuseIdentifier = "UserCell"

    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let premiumBadge: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .systemYellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpLayout() {
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.adjustsFontForContentSizeCategory = true

        detailLabel.font = .preferredFont(forTextStyle: .subheadline)
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(textStack)
        contentView.addSubview(premiumBadge)

        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: premiumBadge.leadingAnchor, constant: -8),

            premiumBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            premiumBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            premiumBadge.widthAnchor.constraint(equalToConstant: 18),
            premiumBadge.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    func configure(with user: User) {
        nameLabel.text = user.fullName
        detailLabel.text = "@\(user.username) · \(user.email)"
        premiumBadge.isHidden = !user.premium
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        premiumBadge.isHidden = true
    }
}
