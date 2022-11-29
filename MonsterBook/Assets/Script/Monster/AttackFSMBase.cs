using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace MonsterFSM
{
    public abstract class AttackFSMBase : MonsterFSMBase
    {
               

        public override abstract void FixedExecute(Rigidbody rigid);        
        public override abstract void UpdateExecute();
        
        public List<Action<Collider>> TriggerFunction;
        public List<Action<Collision>> CollisionFunction;
    }
}

