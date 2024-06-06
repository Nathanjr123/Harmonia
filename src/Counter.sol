// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract Counter {
    struct Profile {
        //profile strutc
        string name;
        uint8 age;
        string gender;
    }
    mapping(address => Profile) private profiles;
    uint256 public numberOfProfiles;  // Counter for profiles

    event ProfileSet(
        address indexed user,
        string name,
        uint8 age,
        string gender
    );

    function setProfile(
        string memory _name,
        uint8 _age,
        string memory _gender
    ) 
    public {
        // Check if profile already exists
        if (bytes(profiles[msg.sender].name).length == 0) {
            numberOfProfiles++;  // Increment counter if new profile
        }

        profiles[msg.sender] = Profile({
            name: _name,
            age: _age,
            gender: _gender
        });
        emit ProfileSet(msg.sender, _name, _age, _gender);
    }
    function getProfile(
        address _user
    ) public view returns (string memory, uint8, string memory) {
        Profile memory profile = profiles[_user];
        return (profile.name, profile.age, profile.gender);
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
