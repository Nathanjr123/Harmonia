// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract Counter {
    enum Interest { Sport, Books, Nature, Animals, Work }

    struct Profile {
        string name;
        uint8 age;
        bool gender;//M or F
        string country;
        Interest interest;
    }

    mapping(address => Profile) private profiles;
    uint256 public numberOfProfiles;  // Counter for profiles
    mapping(address => mapping(address => bool)) private matches;  // Tracks matches between users

    event ProfileSet(
        address indexed user,
        string name,
        uint8 age,
        bool gender,
        string country,
        Interest interest
    );

    event MatchMade(
        address indexed user,
        address indexed matchedWith
    );

    function setProfile(
        string memory _name,
        uint8 _age,
        bool _gender,
        string memory _country,
        Interest _interest
    ) 
    public {
        // Check if profile already exists
        if (bytes(profiles[msg.sender].name).length == 0) {
            numberOfProfiles++;  // Increment counter if new profile
        }

        profiles[msg.sender] = Profile({
            name: _name,
            age: _age,
            gender: _gender,
            country: _country,
            interest: _interest
        });
        emit ProfileSet(msg.sender, _name, _age, _gender, _country, _interest);
    }

    function getProfile(
        address _user
    ) public view returns (string memory, uint8, bool, string memory, Interest) {
        Profile memory profile = profiles[_user];
        return (profile.name, profile.age, profile.gender, profile.country, profile.interest);
    }

    function matchWith(address _user) public {
        require(msg.sender != _user, "You cannot match with yourself");
        require(bytes(profiles[_user].name).length != 0, "User profile does not exist");

        matches[msg.sender][_user] = true;
        emit MatchMade(msg.sender, _user);
    }

    function hasMatched(address _user1, address _user2) public view returns (bool) {
        return matches[_user1][_user2];
    }

    uint256 private number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }

    function increment() public {
        number++;
    }
}
