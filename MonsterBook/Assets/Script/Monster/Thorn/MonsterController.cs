using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public class MonsterController : MonoBehaviour
{
    public enum CurrentState { idle, trace, attack, dead }

    [Header("[Stat]")]
    private string Name = "";
    public float HP = 0.0f;
    public float WalkSpeed = 0.0f;
    public float RunSpeed = 0.0f;
    public float PatrolPoint = 0.0f;
    public float MoveDistance = 0.0f;
    public float AttackDamage = 0.0f;
    public float AttackDistance = 0.0f;
    public float AttackDelay = 0.0f;

    [Header("[State/ScanDist]")]
    public CurrentState State = CurrentState.idle;
    
    private Transform _transform;
    private Transform playerTransform;
    private NavMeshAgent nvAgent;
    public float traceDist = 10.0f;
    public float attackDist = 2.0f;
    private bool isDead = false;

    void Start()
    {
        _transform = this.gameObject.GetComponent<Transform>();
        playerTransform = GameObject.FindWithTag("Player").GetComponent<Transform>();
        nvAgent = this.gameObject.GetComponent<NavMeshAgent>();

        StartCoroutine(this.CheckState());
        StartCoroutine(this.CheckStateForAction());
    }

    // Update is called once per frame
    void Update()
    {
        
    }


    IEnumerator CheckState()
    {
        while(!isDead)
        {
            yield return new WaitForSeconds(0.2f);
            float dist = Vector3.Distance(playerTransform.position, _transform.position);

            if(dist <= attackDist)
            {
                State = CurrentState.attack;
            }
            else if(dist <= traceDist)
            {
                State = CurrentState.trace;
            }
            else
            {
                State = CurrentState.idle;
            }

        }

    }

    IEnumerator CheckStateForAction()
    {
        while(!isDead)
        {
            switch(State)
            {
                case CurrentState.idle:
                    Debug.Log("Idle");
                    this.gameObject.GetComponent<SpriteRenderer>().color = Color.blue;
                    //nvAgent.Stop();
                    break;
                case CurrentState.trace:
                    Debug.Log("trace");
                    this.gameObject.GetComponent<SpriteRenderer>().color = Color.yellow;
                    //nvAgent.destination = playerTransform.position;
                    //nvAgent.Resume();
                    break;
                case CurrentState.attack:
                    this.gameObject.GetComponent<SpriteRenderer>().color = Color.red;
                    Debug.Log("attack");
                    break;

            }
            yield return null;
        }
    }

}
