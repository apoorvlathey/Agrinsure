pragma solidity 0.4.24;

import "../node_modules/chainlink/contracts/ChainlinkClient.sol";

contract MyContract is ChainlinkClient{
    uint256 private oraclePaymentAmount;
    bytes32 private jobId;

    bool public resultReceived;
    int256 public result;

    //for BaseMin to BaseMax -> BasePayout% . for > Max -> MaxPayout%
    uint8 constant floodBaseMin = 111;
    uint8 constant floodBaseMax = 111;
    uint8 constant floodMax = 111;
    uint8 constant floodBasePayout = 50;  //50% of yield
    uint8 constant floodMaxPayout = 100;  //100% of yield

    //for BaseMin to BaseMax -> BasePayout% . for < Min -> MaxPayout%
    uint8 constant droughtBaseMin = 111;
    uint8 constant droughtBaseMax = 111;
    uint8 constant droughtMin = 111;
    uint8 constant droughtBasePayout = 50;  //50% of yield
    uint8 constant droughtMaxPayout = 100;  //100% of yield

    struct cropType {
        string name;
        uint premiumPerAcre;
        uint duration;          //in months
        uint coverage;
    }

    cropType[] public cropTypes;

    enum policyState {Pending, Active, PaidOut, TimedOut}

    struct policy {
        uint policyId;
        address user;
        uint premium;
        uint area;
        uint startTime;
        uint endTime;         //crop's season dependent
        string location;
        uint coverageAmount;  //depends on crop type
        bool forFlood;
        uint8 cropId;
    }

    policy[] public policies;

    function newPolicy (uint _area, string _location, bool _forFlood, uint8 _cropId) public payable{
        require(msg.value == cropTypes[_cropId].premiumPerAcre * _area);
        
        uint pId = policies.length++;
        policy storage p = policies[pId];

        p.user = msg.sender;
        p.premium = cropTypes[_cropId].premiumPerAcre * _area;
        p.area = _area;
        p.startTime = now;
        p.endTime = now + cropTypes[_cropId].duration * 30*24*60*60;  //converting months to seconds
        p.location = _location;
        p.coverageAmount = cropTypes[_cropId].coverage;
        p.forFlood = _forFlood;
        p.cropId = _cropId;
    }

    function newCrop(uint8 _cropId,string _name, uint _premiumPerAcre, uint _duration, uint _coverage) internal {
        cropType memory c = cropType(_name, _premiumPerAcre, _duration, _coverage);
        cropTypes.push(c);
        //cropTypes[_cropId] = c;
    }

    constructor(
        address _link,
        address _oracle,
        bytes32 _jobId,
        uint256 _oraclePaymentAmount
        )
    public
    {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        jobId = _jobId;
        oraclePaymentAmount = _oraclePaymentAmount;

        newCrop(0, "rabi", 1000, 6, 70000);
        newCrop(1, "kharif", 1400, 4, 95000);
    }

    function makeRequest() external returns (bytes32 requestId)
    {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, this, this.fulfill.selector);
        req.add("q", "new york"); //location
        req.add("date", "2019-12-02"); //format: yyyy-MM-dd
        req.add("tp", "24"); //timeperiod 24hrs
        req.add("copyPath", "data.weather.0.hourly.0.precipMM"); //get that day's precipitation in mm
        requestId = sendChainlinkRequestTo(chainlinkOracleAddress(), req, oraclePaymentAmount);
    }

    function resetResult() external
    {
        resultReceived = false;
        result = 0;
    }

    function fulfill(bytes32 _requestId, int256 _result)
    public
    recordChainlinkFulfillment(_requestId)
    {
        resultReceived = true;
        result = _result;
    }
}
