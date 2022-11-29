using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Match_Object_Pool : MonoBehaviour
{
    // Start is called before the first frame update
    public static Match_Object_Pool Instance;

    [SerializeField]
    private GameObject poolingObjectPrefab;
    private GameObject Target_Player;
    private GameObject Target_Anna;

    Queue<Match_Anna> poolingObjectQueue = new Queue<Match_Anna>();

    private void Awake()
    {
        Instance = this;

        Initialize(50);
    }
    
    public void RespownMatch(Vector3 position)
    {
        var match = Match_Object_Pool.GetObject();
        var direction = new Vector3(position.x, position.y, position.z);
        match.transform.position = direction;
        match.GetComponent<Match_Anna>().lookPoint = -1;

    }

    public void RespownHaloMatch(Vector3 position,int i)
    {
        var match = Match_Object_Pool.GetObject();
        var direction = new Vector3(position.x, position.y, position.z);
        match.transform.position = direction;
        match.GetComponent<Match_Anna>().lookPoint = i;
    }

    public void RespownMatch_2(Vector3 position)
    {
        var match = Match_Object_Pool.GetObject();
        var direction = new Vector3(position.x, position.y, position.z);
        match.transform.position = direction;
        match.GetComponent<Match_Anna>().lookPoint = -2;
    }

    private void Initialize(int initCount)
    {
        Target_Player = GameObject.FindWithTag("Player");
        Target_Anna = GameObject.FindWithTag("Anna");
        for (int i = 0; i < initCount; i++)
        {
            poolingObjectQueue.Enqueue(CreateNewObject());

        }
    }

    private Match_Anna CreateNewObject(Transform transform)
    {
        var newObj = Instantiate(poolingObjectPrefab).GetComponent<Match_Anna>();
        newObj.gameObject.SetActive(false);
        newObj.transform.position = transform.position;
        return newObj;
    }
    private Match_Anna CreateNewObject()
    {
        var newObj = Instantiate(poolingObjectPrefab).GetComponent<Match_Anna>();
        newObj.gameObject.SetActive(false);
        newObj.transform.SetParent(transform);
        newObj.Target_Anna = Target_Anna;
        newObj.Target_Player = Target_Player;
        return newObj;
    }

    public static Match_Anna GetObject()
    {
        if (Instance.poolingObjectQueue.Count > 0)
        {
            var obj = Instance.poolingObjectQueue.Dequeue();
            obj.transform.SetParent(null);
            obj.gameObject.SetActive(true);
            return obj;
        }
        else
        {
            var newObj = Instance.CreateNewObject();
            newObj.gameObject.SetActive(true);
            newObj.transform.SetParent(null);
            return newObj;
        }
    }

    public static void ReturnObject(Match_Anna obj)
    {
        obj.gameObject.SetActive(false);
        obj.transform.SetParent(Instance.transform);
        Instance.poolingObjectQueue.Enqueue(obj);
    }

}
