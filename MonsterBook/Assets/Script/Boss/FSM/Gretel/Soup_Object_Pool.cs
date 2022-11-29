using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Soup_Object_Pool : MonoBehaviour
{
    // Start is called before the first frame update
    public static Soup_Object_Pool Instance;

    [SerializeField]
    private GameObject poolingObjectPrefab;

    Queue<Soup> poolingObjectQueue = new Queue<Soup>();

    private void Awake()
    {
        Instance = this;

        Initialize(10);
    }

    public void MakeSoup(Vector3 position)
    {
        var soup = Soup_Object_Pool.GetObject(); 
        soup.GetComponent<Rigidbody>().velocity = Vector3.zero;
        var direction = new Vector3( position.x, position.y, position.z);
        soup.Solid = false;
        soup.transform.position = direction;
        soup.Create();
        soup.GetComponent<Soup>().Effect.GetComponent<ParticleSystem>().Play();
        soup.GetComponent<Rigidbody>().useGravity = true;
    }
    public void MakeSolidSoup(Vector3 position)
    {
        var soup = Soup_Object_Pool.GetObject();
        soup.GetComponent<Rigidbody>().velocity = Vector3.zero;
        var direction = new Vector3(position.x, position.y, position.z);
        soup.Solid = true;
        soup.transform.position = direction;
        soup.Create();
        soup.GetComponent<Soup>().Effect.GetComponent<ParticleSystem>().Play();
        soup.GetComponent<Rigidbody>().useGravity = true;
    }
    private void Initialize(int initCount)
    {
        for (int i = 0; i < initCount; i++)
        {
            poolingObjectQueue.Enqueue(CreateNewObject());
        }
    }

    private Soup CreateNewObject(Transform transform)
    {
        var newObj = Instantiate(poolingObjectPrefab).GetComponent<Soup>();
        newObj.gameObject.SetActive(false);
        newObj.transform.position = transform.position;
        return newObj;
    }
    private Soup CreateNewObject()
    {
        var newObj = Instantiate(poolingObjectPrefab).GetComponent<Soup>();
        newObj.gameObject.SetActive(false);
        newObj.transform.SetParent(transform);
        return newObj;
    }

    public static Soup GetObject()
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

    public static void ReturnObject(Soup obj)
    {
        
        obj.gameObject.SetActive(false);
        obj.transform.SetParent(Instance.transform);
        Instance.poolingObjectQueue.Enqueue(obj);
    }

}
