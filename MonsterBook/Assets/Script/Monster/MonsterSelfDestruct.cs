using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MonsterSelfDestruct : MonoBehaviour
{
    [SerializeField]
    private GameObject monster;
    private MonsterBase Monster;
    private void Start()
    {
        Monster = monster.GetComponent<MonsterBase>();
    }



}
