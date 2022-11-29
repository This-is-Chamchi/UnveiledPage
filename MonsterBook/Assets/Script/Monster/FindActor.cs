using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MonsterFSM;



public class FindActor : MonoBehaviour
{
    // Start is called before the first frame update

    [SerializeField]
    private MonsterBase Monster;
    [SerializeField]
    private bool IsFollowMonster = true;
    private Dictionary<int, MonsterBase> Monsters = new Dictionary<int, MonsterBase>();
    private GameObject Player;
    public bool gIsPlayerChecker => Player != null;
    private Vector3 TargetPos;
    public Vector3 gTargetPos => TargetPos;


    private void Update()
    {
        if (Monster != null && IsFollowMonster)
            transform.position = Monster.transform.position;
    }

    private void OnTriggerEnter(Collider other)
    {
        
        if (other.CompareTag("Monster"))
        {
            var Obj = other.GetComponentInChildren<MonsterBase>();
            if (Obj == null) return;

            Debug.Log (Obj.name);

            if (!Monsters.ContainsKey(Obj.GetHashCode()))
            {
                Monsters.Add(Obj.GetHashCode(), Obj);
                
            }
        }
        else if (other.CompareTag("Player") && Player == null)
        {
            Player = other.gameObject;
            TargetPos = other.transform.position;
        }
    }


    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Monster"))
        {
            var Obj = other.GetComponentInChildren<MonsterBase>();
            if (Obj != null)
            {
                if (Monsters.ContainsKey(Obj.GetHashCode()))
                {
                    Monsters.Remove(Obj.GetHashCode());
                }
            }

        }
        else if (other.CompareTag("Player") && Player != null)
        {
            Player = null;
        }
    }

}
