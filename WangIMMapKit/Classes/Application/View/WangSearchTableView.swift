//
//  WangSearchTableView.swift
//  WangIMMapKit
//
//  Created by Wang on 2025/5/17.
//

import UIKit
import AMapSearchKit

protocol WangSearchTableViewDelegate: AnyObject {
    ///
    func searchMovePOI(poi: AMapPOI, isPoi: Bool)
}
class WangSearchTableView: UIView, WangSearchViewDelegate {
    
    private let options = AMapOptions()
    weak var delegate: WangSearchTableViewDelegate?
    
    lazy var search: AMapSearchAPI = {
        let mapSearch = AMapSearchAPI()
        mapSearch?.delegate = self
        return mapSearch!
    }()
    
    lazy var searchView: WangSearchView = {
        let view = WangSearchView()
        view.delegate = self
        return view
    }()
    
    
    lazy var searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WangSendMapTableViewCell.self, forCellReuseIdentifier: "WangSendMapTableViewCell")
        return tableView
    }()
    
    /// 返回poi数组
    var poisArray: [AMapPOI] = []
    /// 选中的AMapPOI
    lazy var selectMapPoi: AMapPOI = {
        let poi = AMapPOI()
        poi.distance = -1
        return poi
    }()
    /// 标记数组
    var isPoisArray: Bool = true
    var selectPoisArray:[AMapPOI] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.addSubview(self.searchView)
        self.searchView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(45)
        }
        
        self.addSubview(self.searchTableView)
        self.searchTableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.searchView.snp.bottom)
        }
        
    }
    
    /// 搜索POI
    func searchServicePOI(locationCoordinate: CLLocationCoordinate2D) {
        let request = AMapPOIAroundSearchRequest()
        let coor: CLLocationCoordinate2D = locationCoordinate
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coor.latitude), longitude: CGFloat(coor.longitude))
        request.offset = 100;
        self.isPoisArray = true
        self.search.aMapPOIAroundSearch(request)
    }
    /// 根据文字搜索
    func searchSeviceText(text: String) {
        self.isPoisArray = false
        /// 文字为空，回到原位置
        if text.isEmpty {
            self.poisArray = self.selectPoisArray
            self.searchTableView.reloadData()
        }else {
            let request = AMapPOIKeywordsSearchRequest()
            request.keywords = text
            request.city = self.selectMapPoi.city
            self.search.aMapPOIKeywordsSearch(request)
        }
    }
    
    // MARK: - WangSearchViewDelegate
    func searchTextValueChange(text: String, cancel: Bool) {
        if cancel {
            
        }else {
            ///
            searchSeviceText(text: text)
        }
    }
    
}


extension WangSearchTableView: AMapSearchDelegate {
    
    public func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        for item in response.pois {
            if item.uid == self.selectMapPoi.uid {
                return
            }
        }
        self.poisArray.removeAll()
        self.poisArray = response.pois
        if self.isPoisArray {
            self.selectPoisArray = self.poisArray
            if response.pois.count > 0 {
                self.selectMapPoi = response.pois.first ?? selectMapPoi
                delegate?.searchMovePOI(poi: self.selectMapPoi, isPoi: self.isPoisArray)
            }
        }
        self.searchTableView.reloadData()
    }
    
    public func aMapSearchRequest(_ request: Any!, didFailWithError error: (any Error)!) {
        let nsError = error as NSError
        print("错误代码：\(nsError.code)")
        switch nsError.code {
        case 1802:
            print("⚠️ 网络不可用")
        case 1803:
            print("⚠️ 请求超时")
        case 1804:
            print("⚠️ 检索参数有误")
        case 1806:
            print("⚠️ 签名验证失败（检查API Key）")
        default:
            print("未知错误：\(error.localizedDescription)")
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WangSearchTableView: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.poisArray.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        options.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "WangSendMapTableViewCell") as? WangSendMapTableViewCell
        if cell == nil {
            cell = WangSendMapTableViewCell(style: .default, reuseIdentifier: "WangSendMapTableViewCell")
        }
        
        let poi = self.poisArray[indexPath.row]
        cell?.mapPOI(poi: poi, selectPoi: self.selectMapPoi, isPoi: self.isPoisArray)
        return cell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let poi = self.poisArray[indexPath.row]
        self.selectMapPoi = poi
        delegate?.searchMovePOI(poi: self.selectMapPoi, isPoi: self.isPoisArray)
        tableView.reloadData()
        /// 处理键盘(收起键盘)，如果不搜索文字
         searchViewKeyboardHidden()
    }
    
    @objc func searchViewKeyboardHidden() {
        self.searchView.searchButton.isHidden = false
        self.searchView.searchFeild.isHidden = true
        self.searchView.searchFeild.searchFeild.resignFirstResponder()
        self.searchView.searchFeild.searchFeild.text = ""
    }
}


// MARK: - cell
/// cell
class WangSendMapTableViewCell: UITableViewCell {
     private let options = AMapOptions()

    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = options.cellTitleFont
        label.textColor = options.cellTitleColor
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = options.cellSubTitleFont
        label.textColor = options.cellSubTitleColor
        return label
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = options.selectImage
        imageView.isHidden = true
        return imageView
    }()
    
    
    lazy var line: UILabel = {
        let label = UILabel()
        label.backgroundColor = options.separatorColor
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        self.contentView.addSubview(self.tipLabel)
        self.contentView.addSubview(self.subTitleLabel)
        self.contentView.addSubview(self.iconImageView)
        self.contentView.addSubview(self.line)
        
        self.iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(options.selectImageWidth)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        
        self.tipLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalToSuperview().offset(10)
            make.right.equalTo(self.iconImageView.snp.left).offset(-5)
        }
        
        self.subTitleLabel.snp.makeConstraints { make in
            make.left.right.height.equalTo(self.tipLabel)
            make.top.equalTo(self.tipLabel.snp.bottom).offset(5)
        }
        
        self.line.snp.makeConstraints { make in
            make.left.equalTo(self.tipLabel.snp.left)
            make.right.equalTo(self.iconImageView.snp.right)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
    }
    
    func mapPOI(poi: AMapPOI, selectPoi: AMapPOI, isPoi: Bool) {
        self.tipLabel.text = poi.name
        let address = poi.address ?? ""
        if address.isEmpty {
            self.subTitleLabel.text = "\(address)m"
        }else {
            self.subTitleLabel.text = "\(poi.distance)m | \(address)"
        }
        if poi.uid == selectPoi.uid {
            self.iconImageView.isHidden = false
        }else {
            self.iconImageView.isHidden = true
        }
        if !isPoi {
            self.subTitleLabel.text = "\(address)m"
        }
        
    }
}

// MARK： - 搜索控件

protocol WangSearchViewDelegate: AnyObject {
    func searchTextValueChange(text: String, cancel: Bool)
}

class WangSearchView: UIView {
    
    weak var delegate: WangSearchViewDelegate?
    
    lazy var searchButton: WangSearchButton = {
        let btn = WangSearchButton()
        btn.isHidden = false
        btn.addTarget(self, action: #selector(searchViewChange), for: .touchUpInside)
        return btn
    }()
    
    lazy var searchFeild: WangSearchTextField = {
        let textFeild = WangSearchTextField()
        textFeild.isHidden = true
        textFeild.cancelButton.addTarget(self, action: #selector(searchViewChange), for: .touchUpInside)
        textFeild.searchFeild.addTarget(self, action: #selector(searchTextChange(_:)), for: .editingChanged)
        return textFeild
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        self.addSubview(self.searchButton)
        self.searchButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        self.searchButton.roundCorners(radius: 5)
        
        self.addSubview(self.searchFeild)
        self.searchFeild.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    @objc func searchViewChange() {
        self.searchButton.isHidden = !self.searchButton.isHidden
        self.searchFeild.isHidden = !self.searchFeild.isHidden
        if self.searchFeild.isHidden {
            self.searchFeild.searchFeild.resignFirstResponder()
            /// 清空搜索框
            self.searchFeild.searchFeild.text = ""
            delegate?.searchTextValueChange(text: "", cancel: true)
        }else {
            self.searchFeild.searchFeild.becomeFirstResponder()
        }
    }
    /// 根据文字搜索
    @objc func searchTextChange(_ textFiled: UITextField) {
        let text = textFiled.text ?? ""
        delegate?.searchTextValueChange(text: text, cancel: false)
    }
    
    
}

class WangSearchTextField: UIView {
    private let options = AMapOptions()
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        return btn
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = options.searchBgColor
        return view
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = options.searchIconImage
        return imageView
    }()
    
    lazy var searchFeild: UITextField = {
        let feild = UITextField()
        feild.attributedPlaceholder = NSAttributedString(
            string: options.searchTitle,
            attributes: [
                .foregroundColor: options.searchPlaceholderColor,
                .font: options.searchTitleFont
            ]
        )
        feild.textAlignment = .left
        feild.font = options.searchTitleFont
        feild.backgroundColor = .clear
        return feild
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.addSubview(self.cancelButton)
        self.cancelButton.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(55)
        }
        self.addSubview(self.containerView)
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.right.equalTo(self.cancelButton.snp.left)
        }
        self.containerView.roundCorners(radius: 5)
        
        self.containerView.addSubview(self.iconImageView)
        self.iconImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(35)
        }
        self.containerView.addSubview(self.searchFeild)
        self.searchFeild.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(self.iconImageView.snp.right).offset(5)
        }
        
        
    }
    
    
}

class WangSearchButton: UIButton {
    private let options = AMapOptions()
    lazy var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = options.searchIconImage
        return imageView
    }()
    
    lazy var newTitleLabel: UILabel = {
        let label = UILabel()
        label.text = options.searchTitle
        label.font = options.searchTitleFont
        label.textColor = options.searchTitleColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = options.searchBgColor
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        self.addSubview(self.newTitleLabel)
        self.newTitleLabel.snp.makeConstraints { make in
            make.height.top.equalToSuperview()
            make.centerX.equalToSuperview().offset(15)
        }
        
        self.addSubview(self.bgImageView)
        self.bgImageView.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.left.equalTo(self.newTitleLabel.snp.left).offset(-35)
            make.centerY.equalToSuperview()
        }
    }
}
