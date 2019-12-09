pragma solidity 0.4.24;

import "../node_modules/chainlink/contracts/ChainlinkClient.sol";
import "DateTime.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract MyContract is ChainlinkClient{
    using strings for *;

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
        uint premiumPerAcre;    //in wei
        uint duration;          //in months
        uint coveragePerAcre;   //in wei
    }

    cropType[2] public cropTypes; //crops defined in constructor

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
        policyState state;
    }

    policy[] public policies;

    mapping(address => uint[]) public userPolicies;  //user address to array of policy IDs

    function newPolicy (uint _area, string _location, bool _forFlood, uint8 _cropId) external payable{
        require(msg.value == (cropTypes[_cropId].premiumPerAcre * _area),"Incorrect Premium Amount");

        uint pId = policies.length++;
        userPolicies[msg.sender].push(pId);
        policy storage p = policies[pId];

        p.user = msg.sender;
        p.premium = cropTypes[_cropId].premiumPerAcre * _area;
        p.area = _area;
        p.startTime = now;
        p.endTime = now + cropTypes[_cropId].duration * 30*24*60*60;  //converting months to seconds
        p.location = _location;
        p.coverageAmount = cropTypes[_cropId].coveragePerAcre * _area;
        p.forFlood = _forFlood;
        p.cropId = _cropId;
        p.state = policyState.Active;
    }

    function newCrop(uint8 _cropId,string _name, uint _premiumPerAcre, uint _duration, uint _coveragePerAcre) internal {
        cropType memory c = cropType(_name, _premiumPerAcre, _duration, _coveragePerAcre);
        cropTypes[_cropId] = c;
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

        newCrop(0, "rabi", 1, 6, 7);
        newCrop(1, "kharif", 2, 4, 10);
    }

    function claim(uint _policyId, uint _timestamp) external {
        require(msg.sender == policies[_policyId].user, "User Not Authorized");

        string location = policies[_policyId].location;

        uint8 year = getYear(_timestamp);
        string y = uintToString(year);
        uint8 month = getMonth(_timestamp);
        string m = uintToString(month);
        uint8 day = getDay(_timestamp);
        string d = uintToString(day);

        string date = y.toSlice().concat("-".toSlice());
        date = date.toSlice().concat(m.toSlice());
        date = date.toSlice().concat("-".toSlice());
        date = date.toSlice().concat(d.toSlice());

    }

    function makeRequest(string _location, string _date) internal returns (bytes32 requestId)
    {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, this, this.fulfill.selector);
        req.add("q", _location);      //location
        req.add("date", _date); //format: yyyy-MM-dd
        req.add("tp", "24");           //timeperiod 24hrs
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

    function uintToString(uint v) constant returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        str = string(s);
    }
}
