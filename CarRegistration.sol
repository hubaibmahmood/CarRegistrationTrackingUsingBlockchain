pragma solidity ^0.5.0;

import "./DappToken.sol";

contract CarRegistry
{
    DappToken dappToken;
    address owner;
    enum CarState {Available, Owned}
    enum RequestState {Approved, Pending}
    struct Car
    {
        uint id;
        uint price;
        address payable owner;
        string name;
        uint model;
        address requestee;
        CarState state;
    }
    struct User
    {
        string name;
        string cnic;
        address payable wallet_address;
    }
    
    mapping(uint256 => Car) cars;
    mapping(address => User) users;
    mapping(address => RequestState) public request;
    
    
    constructor (DappToken _dapptoken) public {
        
        dappToken = _dapptoken;
		owner = msg.sender;
	}

    
    function add_car(uint _id, uint _price, string memory _state, string memory name, uint model) public
    {
        if(keccak256(bytes(_state)) == keccak256(bytes("Owned")))
            cars[_id] = (Car(_id, 0, msg.sender, name, model,  msg.sender, CarState.Owned));
        else
            cars[_id] = (Car(_id, _price, msg.sender,name, model,  msg.sender, CarState.Available));
    }
    
    function add_user(string memory _name, string memory _cnic) public
    {
        users[msg.sender] = User(_name, _cnic, msg.sender);
        
    }
    
    function buy_car(uint256 _id) public payable
    {
        require(dappToken.balanceOf(msg.sender) >= cars[_id].price, "You don't have enough balance");
        require(cars[_id].state == CarState.Available, "Car not Available");
        require(request[msg.sender] == RequestState.Approved, "Request is pending, please wait or make a request");
        address _owner = cars[_id].owner;
        uint _price = cars[_id].price;
        dappToken.transferFrom(msg.sender, _owner, _price);
        
        cars[_id].state = CarState.Owned;
        cars[_id].owner = msg.sender;
        cars[_id].price = 0;
    }
    
    function request_to_buy(uint _index) public
    {
        cars[_index].requestee = msg.sender;
        request[msg.sender] = RequestState.Pending;
    }
    
    function approve_request(address user_address, uint _index) public
    {
        require(cars[_index].owner != cars[_index].requestee, "No requests");
        require(msg.sender == cars[_index].owner, "Only the car owner can accept the request");
        request[user_address] = RequestState.Approved;
    }
    
    function show_requestee(uint _index) public view returns(address)
    {
        return (cars[_index].requestee);
    }
    
    function show_car(uint _index) public view returns(uint, uint, address, CarState, string memory, string memory, uint)
    {
        return (cars[_index].id, cars[_index].price, cars[_index].owner, cars[_index].state, users[cars[_index].owner].name, cars[_index].name, cars[_index].model);
    }
    
    
}

