using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MonsterFSM;

public interface MonsterFSMInterface 
{    
    public void FixedExecute(Rigidbody rigid);
    public void UpdateExecute();
    //public MonsterFSMBase Transition();    

}